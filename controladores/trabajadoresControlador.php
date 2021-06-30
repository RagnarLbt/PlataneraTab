<?php
	if ($peticionAjax) {
		require_once "../modelos/trabajadoresModelo.php";
	} else {
		require_once "./modelos/trabajadoresModelo.php";
	}

	class trabajadoresControlador extends trabajadoresModelo{


		public function registroTrabajadorControlador(){
			$foto=$_POST['foto'];
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
            $edad=$_POST['edad'];
            $tel=$_POST['tel'];
            $dir=$_POST['dir'];
            $cuenta=$_POST['cuenta'];
            $tipo=mainModel::limpiar_cadena($_POST['tipo']);
            $ruta=null;

            if($foto!='' || $foto!=null){
            	list(,$foto)=explode(';', $foto);
				list(,$foto)=explode(',', $foto);
				
				$name_foto=$tipo."-".$nombre." ".$app;
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
				"Foto"=>$ruta,
				"opc"=>$tipo
			];

			$sql=trabajadoresModelo::registroTrabajadorModelo($datos);

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return "Error";
			}

		}

		public function actualizarTrabajadorControlador(){
			$id=mainModel::limpiar_cadena($_POST['id']);
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
			$apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
			$edad=$_POST['edad'];
            $tel=$_POST['tel'];
            $dir=$_POST['dir'];
            $cuenta=$_POST['cuenta'];
			$tipo=mainModel::limpiar_cadena($_POST['tipo']);
			$foto=$_POST['foto'];
			$aux=$_POST['aux'];
			$nombreAux=$_POST['nombreaux'];
			$ruta="";
			$name_foto="";

			if($foto!=$aux){
				list(,$foto)=explode(';', $foto);
				list(,$foto)=explode(',', $foto);
				
				$name_foto=$tipo."-".$nombre."_".$app;
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
				"Foto"=>$ruta,
				"opc"=>$tipo
			];

			$sql=trabajadoresModelo::actualizarTrabajadorModelo($datos);
			
			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return "Error";
			}
		}

		public function eliminarTrabajadorControlador(){
			$id=$_POST['id'];
			$tipo=$_POST['tipoTrabajador'];
			$estado=$_POST['estado'];

			$datos=[
				"Id" => $id,
				"opc"=> $tipo,
				"estado"=>$estado
			];

			$sql=trabajadoresModelo::eliminarTrabajadorModelo($datos);

			if($sql->rowCount()==1){
				return "OK";
			}else{
				return $sql;
			}
		}

		public function listaPeladorControlador(){
			$sql=trabajadoresModelo::listaPeladoresModelo();
			return $sql;
		}

		public function listaBolseroControlador(){
			$sql=trabajadoresModelo::listaBolserosModelo();
			return $sql;
		}

		public function listaTostonControlador(){
			$sql=trabajadoresModelo::listaTostonModelo();
			return $sql;
		}

		public function listaGeneralControlador(){
			$sql=trabajadoresModelo::listaGeneralModelo();
			return $sql;
		}

		public function listaEmbarquePeladorControlador(){
			$sql=trabajadoresModelo::listaEmbarquePeladoresModelo();
			return $sql;
		}

		public function listaEmbarqueBolseroControlador(){
			$sql=trabajadoresModelo::listaEmbarqueBolserosModelo();
			return $sql;
		}

		public function listaEmbarqueTostonControlador(){
			$sql=trabajadoresModelo::listaEmbarqueTostonModelo();
			return $sql;
		}

	}