<?php
	if ($peticionAjax) {
		require_once "../modelos/loginModelo.php";
	} else {
		require_once "./modelos/loginModelo.php";
	}

	class loginControlador extends loginModelo{
		
		public function iniciar_sesion_controlador(){
			$usuario=strtolower($_POST['usuario']);
			$clave=strtolower($_POST['clave']);
			
			$clave=mainModel::encryptar($clave);
			
			$datosLogin=[
				"usuario"=> $usuario,
				"contra"=> $clave
			];

			$datosInicio=loginModelo::iniciar_sesion_modelo($datosLogin);

			if($datosInicio->rowCount()==1){
				$row=$datosInicio->fetch();

				session_start(['name'=>'PLATANERATAB']);
				$_SESSION['id_user']=$row['id'];
				$_SESSION['user_name']=$row['user'];
				$_SESSION['nombre']=$row['nombre'];
				$_SESSION['tipo']=$row['tipo'];
				//$_SESSION['genero']=$row['genero'];
				$_SESSION['token']=md5(uniqid(mt_rand(),true));

				$url=SERVERURL."embarque/";
				


				return $urlLocation='<script>localStorage.tablero=true; window.location="'.$url.'"</script>';

			}else{
				
				$alerta=[
					"Alerta"=>"simple",
					"Titulo"=>"Ocurrio un error inesperado",
					"Texto"=>"El nombre de usuario y contraseña no son correctos",
					"Tipo"=>"error"
				];

				return mainModel::sweet_alert($alerta);

			}

		}

		public function buscarUsuario(){
			$user=strtolower($_POST['user']);
			$pass=strtolower($_POST['pass']);
			$opc=$_POST['valor'];

			$clave=mainModel::encryptar($pass);

			$datosLogin=[
				"usuario"=> $user,
				"contra"=> $clave
			];

			$datosInicio=loginModelo::iniciar_sesion_admin($datosLogin);

			if($datosInicio->rowCount()>=1){
				return "OK".$opc;
			}else{
				return "Error";
			}
		}

		public function finalizar_sesion_controlador(){
			session_start(['name'=>'PLATANERATAB']);
			$token=mainModel::desencryptar($_GET['token']);
			
			$datos=[
				"usuario"=>$_SESSION['user_name'],
				"token_p"=>$_SESSION['token'],
				"token"=>$token
			];

			return loginModelo::finalizar_sesion_modelo($datos);
		}

		public function cerrar_sesion_controlador(){
			session_destroy();
			return header("Location: ".SERVERURL."login/");
		}
	}