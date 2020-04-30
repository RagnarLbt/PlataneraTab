<?php

$peticionAjax=true;
require_once "../core/configGeneral.php";

$_POST= json_decode(file_get_contents("php://input"), true);

    if(isset($_POST['option'])){
        
        require_once "../controladores/administradorControlador.php";
        $instAdmin= new administradorControlador();

            if (isset($_POST['option'])&& $_POST['option']== 1){
                echo $instAdmin->agregar_admin_controlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 2){
                echo $instAdmin->eliminar_admin_controlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 3){
               $data= $instAdmin->lista_admin_controlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 4){
               $data=$instAdmin->buscar_admin_controlador();
            }

            print json_encode($data, JSON_UNESCAPED_UNICODE);

    } else{
        session_start();
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
    }