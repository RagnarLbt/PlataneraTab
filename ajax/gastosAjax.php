<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){
		
		require_once "../controladores/gastosControlador.php";
		$intgastos= new gastosControlador();

		if(isset($_POST['option']) && $_POST['option'] == 1){
			$data = $intgastos->obtenerEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 2){
			$data = $intgastos->buscarGastosControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 3){
			$data = $intgastos->listaGastosControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 4){
			$data = $intgastos->registroGastosControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 5){
			$data = $intgastos->listaGastosRegistradosControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 6){
			$data = $intgastos->getPrecioControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 7){
			echo $intgastos->updatePrecioControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 8){
			echo $intgastos->registroGastoNuevoControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 9){
			echo $intgastos->eliminarTipoGastoControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 10){
			echo $intgastos->modificarTipoGastoControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 11){
			$data = $intgastos->modificarGastoControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 13){
			$data = $intgastos->eliminarGastoControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 12){
			$data = $intgastos->listarTodosLosGastosControlador();
		}

		print json_encode($data, JSON_UNESCAPED_UNICODE);

	}else{
		session_start(['name'=>'PLATANERATAB']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}