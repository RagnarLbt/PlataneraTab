<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){

		require_once "../controladores/embarqueControlador.php";
		$intEmbarque= new embarqueControlador();

		if(isset($_POST['option']) && $_POST['option'] == 1){
			$data = $intEmbarque->crearEmbarqueControlador();
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
			$data = $intEmbarque->asistenciaEmbarqueControlador();
		}

		/* Registro de frutas al embarque */
		if(isset($_POST['option']) && $_POST['option'] == 6){
			$data= $intEmbarque->frutaEmbarqueControlador();
		}

		/* Lista de frutas vigente del embarque */
		if(isset($_POST['option']) && $_POST['option'] == 7){
			$data = $intEmbarque->listafrutaEmbarqueControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 8){
			$data = $intEmbarque->mostrarCard_controlador();
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

		/* Añadir Bolsa al Embarque, Pelador y Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 111){
			$data = $intEmbarque->addBolsasPeladorEmbarqueControlador();
		}

		/* Finalizar Embarque */
		if(isset($_POST['option']) && $_POST['option'] == 12){
			$data = $intEmbarque->finalizarEmbarqueControlador();
		}

		/* Registro en la Tabla Planilla y Gastos de Planilla */
		if(isset($_POST['option']) && $_POST['option'] == 13){
			$data = $intEmbarque->registroPlanillaToston();
		}

		/* Obteniendo datos del Tablero */
		if(isset($_POST['option']) && $_POST['option'] == 14){
			$data = $intEmbarque->listaBosasDia($_POST['embarque'], $_POST['fecha']);
		}

		/* Obteniendo embarques para las cuentas */
		if(isset($_POST['option']) && $_POST['option'] == 15){
			$data = $intEmbarque->obtenerEmbCuentaControlador();
		}

		/* Obteniendo lista de bolsa producidas en el día */
		if(isset($_POST['option']) && $_POST['option'] == 16){
			$data = $intEmbarque->obtenerBolsasDiaControlador();
		}

		/* Actualizar datos de una bolsa producida en el día */
		if(isset($_POST['option']) && $_POST['option'] == 17){
			$data = $intEmbarque->actualizarBolsasDiaControlador();
		}

		/* Registrar Bolseros Extras */
		if(isset($_POST['option']) && $_POST['option'] == 18){
			$data = $intEmbarque->addBolsasExtraControlador();
		}

		/* Lista de Bolseros Extras */
		if(isset($_POST['option']) && $_POST['option'] == 19){
			$data = $intEmbarque->listaBolsasExtraControlador();
		}

		/* Modificar Bolseros Extras */
		if(isset($_POST['option']) && $_POST['option'] == 20){
			$data = $intEmbarque->modBolsasExtraControlador();
		}

		/* Eliminar Bolseros Extras */
		if(isset($_POST['option']) && $_POST['option'] == 21){
			$data = $intEmbarque->deleteBolsasExtraControlador();
		}

		/* Añadir trabajo extra a Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 22){
			$data = $intEmbarque->extraBolsasControlador();
		}

		/* Lista de trabajos extras de los Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 23){
			$data = $intEmbarque->listaBolserosOtrosControlador();
		}

		/* Modificar trabajos extras de los Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 24){
			$data = $intEmbarque->modBolseroOtroControlador();
		}

		/* Eliminar trabajos extras de los Bolsero */
		if(isset($_POST['option']) && $_POST['option'] == 25){
			$data = $intEmbarque->deleteBolseroOtroControlador();
		}

		/*Prestamos a Productores - Registro */
		if(isset($_POST['option']) && $_POST['option'] == 26){
			$data = $intEmbarque->addPrestamoControlador();
		}

		/*Cantidades de Prestamos adeudadas de un Productor */
		if(isset($_POST['option']) && $_POST['option'] == 27){
			$data = $intEmbarque->getPrestamoControlador();
		}

		/*Abono de Prestamos a Productores - Registro */
		if(isset($_POST['option']) && $_POST['option'] == 28){
			$data = $intEmbarque->addAbonoControlador();
		}
		/*Imprimir Etiqueta de una Bolsa */
		if(isset($_POST['option']) && $_POST['option'] == 29){
			echo $intEmbarque->imprimirEtiqueta($_POST['prod'], $_POST['dia'], $_POST['bol'], $_POST['pel'], $_POST['h'], $_POST['f'], $_POST['num']);
		}

		if(isset($_POST['option']) && $_POST['option'] == 30){
			$data = $intEmbarque->verResumenControlador();
		}

		//Agregar trabajo pelador
		if(isset($_POST['option']) && $_POST['option'] == 32){
			$data = $intEmbarque->addPeladorextra();
		}
		//actualizar trabajo pelador
		if(isset($_POST['option']) && $_POST['option'] == 33){
			$data = $intEmbarque->updatePeladorExtra();
		}
		//delete trabajo pelador
		if(isset($_POST['option']) && $_POST['option'] == 34){
			$data = $intEmbarque->deletePeladorExtra();
		}
		//listar peladores bolseros
		if(isset($_POST['option']) && $_POST['option'] == 35){
			$data = $intEmbarque->listarPeladoresExtra_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 36){
			$data = $intEmbarque->listarBolserosTodos_controlador();
		}
		
		if(isset($_POST['option']) && $_POST['option'] == 37){
			$data = $intEmbarque->finPeladorExtra_controlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 38){
			$data = $intEmbarque->listarFrutaCapturada();
		}

		if(isset($_POST['option']) && $_POST['option'] == 39){
			$data = $intEmbarque->modificarFrutaCapturada();
		}

		if(isset($_POST['option']) && $_POST['option'] == 40){
			$data = $intEmbarque->eliminarFrutaCapturada();
		}

		if(isset($_POST['option']) && $_POST['option'] == 41){
			$data = $intEmbarque->obtenerRendimiento();
		}

		if(isset($_POST['option']) && $_POST['option'] == 42){
			$data = $intEmbarque->listaPeladoresControlador();
		}

		if(isset($_POST['option']) && $_POST['option'] == 43){
			$data = $intEmbarque->listaRend();
		}

		if(isset($_POST['option']) && $_POST['option'] == 44){
			$data = $intEmbarque->listaPelador();
		}
		
        print json_encode($data, JSON_UNESCAPED_UNICODE);

	}else{
		session_start(['name'=>'PT']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}