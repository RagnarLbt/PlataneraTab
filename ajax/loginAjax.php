<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){

		require_once "../controladores/embarqueControlador.php";
		$intLogin= new loginControlador();

		if(isset($_POST['option']) && $_POST['option'] == 1){
			//echo $intLogin->Controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 2){
			//$data = $intLogin->seleccionLoginControlador();
		}

		print json_encode($data, JSON_UNESCAPED_UNICODE);
	
	}else{
		session_start(['name'=>'PT']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}