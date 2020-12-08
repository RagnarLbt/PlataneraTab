<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);
	
	require_once "../controladores/loginControlador.php";
	$cerrarSesion= new loginControlador();
	
	if(isset($_GET['token'])){

		if(isset($_GET['token'])){
			echo $cerrarSesion->finalizar_sesion_controlador();
		}

	}elseif(isset($_POST['option'])){

		if(isset($_POST['option']) && $_POST['option']==2){
			$data = $cerrarSesion->buscarUsuario();
		}

		print json_encode($data, JSON_UNESCAPED_UNICODE);
		
	}else{
		session_start(['name'=>'PLATANERATAB']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';

	}