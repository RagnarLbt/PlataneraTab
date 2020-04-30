<?php
	if ($peticionAjax) {
		require_once"../core/configApp.php";
	} else {
		require_once "./core/configApp.php";
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

		protected function agregar_cuenta($datos){
			
		}

		protected function eliminar_cuenta($id){
			
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

	}