<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){

		require_once "../controladores/bancoControlador.php";
		$intsBanco= new bancoControlador();

		if(isset($_POST['option']) && $_POST['option'] == 1){
			$data = $intsBanco->listaDolares_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 2){
			$data= $intsBanco->agregarDolares();
		}

		if(isset($_POST['option']) && $_POST['option'] == 3){
			$data = $intsBanco->total_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 4){
			$data = $intsBanco->listaPesos_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 5){
			$data = $intsBanco->totalPesos_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 6){
			echo $intsBanco->agregarPesos();
		}

		if(isset($_POST['option']) && $_POST['option'] == 7){
			echo $intsBanco->agregarBolsas();
		}

		if(isset($_POST['option']) && $_POST['option'] == 8){
			$data = $intsBanco->totalBolsas_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 9){
			$data = $intsBanco->listaBolsas_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 10){
			$data= $intsBanco->cerrarCuenta_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 11){
			$data = $intsBanco->resumen_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 12){
			$data = $intsBanco->actualizarBanco();
		}

		if(isset($_POST['option']) && $_POST['option'] == 13){
			$data = $intsBanco->deleteBancos();
		}

		print json_encode($data, JSON_UNESCAPED_UNICODE);

	}else{
		session_start(['name'=>'PT']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}