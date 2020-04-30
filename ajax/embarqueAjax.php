<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){

		require_once "../controladores/embarqueControlador.php";
		$intEmbarque= new embarqueControlador();

		if(isset($_POST['option']) && $_POST['option'] == 1){
			echo $intEmbarque->crearEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 2){
			$data = $intEmbarque->seleccionEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 3){
			echo $intEmbarque->finalizarEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 4){
			$data = $intEmbarque->obtenerEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 5){
			echo $intEmbarque->asistenciaEmbarqueControlador();
		}

		/* Registro de frutas al embarque */
		if(isset($_POST['option']) && $_POST['option'] == 6){
			echo $intEmbarque->frutaEmbarqueControlador();
		}

		/* Lista de frutas vigente del embarque */
		if(isset($_POST['option']) && $_POST['option'] == 7){
			$data = $intEmbarque->listafrutaEmbarqueControlador();
		}

		/* Lista de trabajadores asistentes del dia */
		/* Peladores */
		if(isset($_POST['option']) && $_POST['option'] == 8){
			$data = $intEmbarque->peladoresDiaEmbarqueControlador();
		}

		/* Bolseros */
		if(isset($_POST['option']) && $_POST['option'] == 9){
			$data = $intEmbarque->bolserosDiaEmbarqueControlador();
		}

		/* Finalizar Día de Trabajo */
		if(isset($_POST['option']) && $_POST['option'] == 10){
			$data = $intEmbarque->finalizarDiaEmbarqueControlador();
		}

		/* Añadir Bolsa al Embarque, Pelador y Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 11){
			$data = $intEmbarque->addBolsaEmbarqueControlador();
		}

		/* Finalozar Embarque */
		if(isset($_POST['option']) && $_POST['option'] == 12){
			$data = $intEmbarque->finalizarEmbarqueControlador();
		}

        print json_encode($data, JSON_UNESCAPED_UNICODE);

	}else{
		session_start(['name'=>'PT']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}