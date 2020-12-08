<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";

	//Axios
	$_POST = json_decode(file_get_contents("php://input"), true);

	if(isset($_POST['option'])){

		require_once "../controladores/productorControlador.php";
		$intProductor= new productorControlador();

                if(isset($_POST['option']) && $_POST['option'] == 1){
                        $data =$intProductor->registroProductorControlador();
                }

                if(isset($_POST['option']) && $_POST['option'] == 2){
                	$data = $intProductor->actualizarProductorControlador();
                }

                if(isset($_POST['option']) && $_POST['option'] == 3){
                	$data = $intProductor->eliminarProductorControlador();
                }

                if(isset($_POST['option']) && $_POST['option'] == 4){
                	$data = $intProductor->listaProductorControlador();
                }

                if(isset($_POST['option']) && $_POST['option'] == 5){
                        $data = $intProductor->listaOidenadaProductorControlador();
                }

                print json_encode($data, JSON_UNESCAPED_UNICODE);

	}else{
		session_start(['name'=>'PT']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
	}