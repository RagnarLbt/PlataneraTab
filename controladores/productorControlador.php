<?php
	if ($peticionAjax) {
		require_once "../modelos/productorModelo.php";
	} else {
		require_once "./modelos/productorModelo.php";
	}

	class productorControlador extends productorModelo{

		public function registroProductorControlador(){
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
            $edad=$_POST['edad'];
            $tel=$_POST['tel'];
            $dir=$_POST['dir'];
            $cuenta=$_POST['cuenta'];
            $foto=$_POST['foto'];

            if($foto!='' || $foto!=null){
            	list(,$foto)=explode(';', $foto);
				list(,$foto)=explode(',', $foto);
				
				$name_foto="PROD-".$nombre." ".$app;
				$img=base64_decode($foto);

				$filepath='../vistas/assets/avatars/'.$name_foto.'.png';
				$ruta = "http://localhost/PLATANERATAB/vistas/assets/avatars/".$name_foto.".png";
				file_put_contents($filepath, $img);

            }else{
            	$ruta = "http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png";
            }

            $datos=[
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm,
				"Edad"=>$edad,
				"Tel"=>$tel,
				"Dir"=>$dir,
				"Cuenta"=>$cuenta,
				"Foto"=>$ruta
			];

			$sql=productorModelo::registroProductorModelo($datos);

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}
		}

		public function actualizarProductorControlador(){
			$id=mainModel::limpiar_cadena($_POST['id']);
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
            $edad=$_POST['edad'];
            $tel=$_POST['tel'];
            $dir=$_POST['dir'];
            $cuenta=$_POST['cuenta'];
            $foto=$_POST['foto'];
			$aux=$_POST['aux'];
			$nombreAux=$_POST['nombreaux'];
			$ruta="";
			$name_foto="";

            if($foto!=$aux){
				list(,$foto)=explode(';', $foto);
				list(,$foto)=explode(',', $foto);
				
				$name_foto="PROD-".$nombre."_".$app;
				$img=base64_decode($foto);

				$filepath='../vistas/assets/avatars/'.$name_foto.'.png';
				file_put_contents($filepath, $img);
				if($nombreAux!=$name_foto){
					$ruta = "http://localhost/PLATANERATAB/vistas/assets/avatars/".$name_foto.".png";
				}else{
					$ruta = $foto;
				}
			}else{
				$ruta = $foto;
			}

            $datos=[
				"Id" => $id,
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm,
				"Edad"=>$edad,
				"Tel"=>$tel,
				"Dir"=>$dir,
				"Cuenta"=>$cuenta,
				"Foto"=>$ruta
			];
			
			$sql=productorModelo::actualizarProductorModelo($datos);

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}
		}

		public function eliminarProductorControlador(){
			$id = mainModel::limpiar_cadena($_POST['id']);
			
			$sql=productorModelo::eliminarProductorModelo($id);
			return $sql;
		}

		public function listaProductorControlador(){
			$sql=productorModelo::listaProductorModelo();
			return $sql;
		}

		public function listaOidenadaProductorControlador(){
			$sql=productorModelo::listaOrdenadaProductorModelo();
			return $sql;
		}

	}