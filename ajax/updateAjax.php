<?php

$peticionAjax=true;
require_once "../core/configGeneral.php";

$_POST= json_decode(file_get_contents("php://input"), true);

    if(isset($_POST['option'])){
        
        require_once "../controladores/updateControlador.php";
        $instU= new updateControlador();


        if (isset($_POST['option'])&& $_POST['option']== 1){
           $data= $instU->listaEmb_controlador();
        }

        if(isset($_POST['option'])&& $_POST['option']== 100){
            $data=$instU->listaEmbActivos_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 2){
            $data= $instU->listaProd_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 5){
            $data= $instU->updateProd_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 3){
            $data= $instU->listaToston_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 4){
            $data= $instU->totalesProd_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 6){
            $data= $instU->updateToston_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 7){
            $data= $instU->totalToston_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 8){
            $data= $instU->listaBolseros_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 9){
            $data= $instU->totalBolseros_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 10){
         $data= $instU->updateBolseros_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 11){
           $data= $instU->listaBolserosExtra_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 12){
            $data= $instU->totalBolserosExtra_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 13){
            $data= $instU->updateBolserosExtra_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 14){
            $data= $instU->deleteToston_controlador();
        }

        if (isset($_POST['option'])&& $_POST['option']== 15){
            $data= $instU->listaToston();
        }

        if (isset($_POST['option'])&& $_POST['option']== 16){
            $data= $instU->agregarToston();
        }

        if (isset($_POST['option'])&& $_POST['option']== 17){
            $data= $instU->deleteBolsero();
        }

        if (isset($_POST['option'])&& $_POST['option']== 18){
            $data= $instU-> insertBolsero();
        }

        print json_encode($data, JSON_UNESCAPED_UNICODE);

    } else{
        session_start();
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
    }