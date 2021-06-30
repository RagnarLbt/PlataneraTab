<?php
	if(isset($pdf)){
		require_once "../../core/configApp.php";
	}else{
		if ($peticionAjax) {
			require_once"../core/configApp.php";
		} else {
			require_once "./core/configApp.php";
		}
	}

	class mainModel{

		protected function conectar(){
			$enlace = new PDO(SGBD, USER, PASSWORD);
			return $enlace;
		}

		protected function ejecutar_consulta_simple($sql){
			$respuesta=self::conectar()->prepare($sql);
			$respuesta->execute();
			return $respuesta;
		}

		public function consulta($sql){
			$respuesta=self::conectar()->prepare($sql);
			$respuesta->execute();
			return $respuesta;
			$areglo=array();
			while ($data=$respuesta->fetch()) {
				$arreglo[]=$data;
			}
			return $arreglo;
		}

		public function generaId($tabla, $embarque){
			$sql=self::ejecutar_consulta_simple("SELECT COUNT(id) FROM `$tabla` WHERE id_embarque=$embarque");
			$id=$sql->fetch();
			return $embarque.''.($id[0]+1);
		}

		public function encryptar($string){
			$output=FALSE;
			$key=hash('sha256', SECRET_KEY);
			$iv=substr(hash('sha256', SECRET_IV), 0, 16);
			$output=openssl_encrypt($string, METHOD, $key, 0, $iv);
			$output=base64_encode($output);
			return $output;
		}

		protected function desencryptar($string){
			$key=hash('sha256', SECRET_KEY);
			$iv=substr(hash('sha256', SECRET_IV), 0, 16);
			$output=openssl_decrypt(base64_decode($string), METHOD, $key, 0, $iv);
			return $output;
		}

		protected function limpiar_cadena($cadena){
			$cadena=trim($cadena);
			$cadena=stripcslashes($cadena);
			$cadena=str_ireplace("*", "", $cadena);
			$cadena=str_ireplace("-", "", $cadena);
			$cadena=str_ireplace("+", "", $cadena);
			$cadena=str_ireplace("/", "", $cadena);
			$cadena=str_ireplace(".", "", $cadena);
			$cadena=str_ireplace(",", "", $cadena);
			$cadena=str_ireplace(";", "", $cadena);
			$cadena=str_ireplace(":", "", $cadena);
			$cadena=str_ireplace("_", "", $cadena);
			$cadena=str_ireplace("<", "", $cadena);
			$cadena=str_ireplace(">", "", $cadena);
			$cadena=str_ireplace("¿", "", $cadena);
			$cadena=str_ireplace("?", "", $cadena);
			return $cadena;
		}

		protected function sweet_alert($datos){
			if($datos['Alerta']=="simple"){
				$alerta="
					<script>
						Swal.fire({
							title:'".$datos['Titulo']."',
							text:'".$datos['Texto']."',
							icon:'".$datos['Tipo']."',
							backdrop: false
						});
					</script>";
			}elseif($datos['Alerta']="recarga"){
				$alerta="
					<script>
						Swal.fire({
							title: '".$datos['Titulo']."',
							text: '".$datos['Texto']."',
							type: '".$datos['Tipo']."',
							confirmButtonText: 'Aceptar'
							}).then(function () {
								location.reload();
							});
					</script>";
			}elseif($datos['Alerta']="limpiar"){
				$alerta="
					<script>
						Swal.fire({
							title: '".$datos['Titulo']."',
							text: '".$datos['Texto']."',
							type: '".$datos['Ttipo']."',
							confirmButtonText: 'Aceptar'
							}).then(function () {
								$('.FormularioAjax')[0].reset();
							});
					</script>";
			}

			return $alerta;
		}

	}