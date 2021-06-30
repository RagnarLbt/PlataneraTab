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
                echo $instAdmin->eliminarAdminControlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 3){
               $data= $instAdmin->lista_admin_controlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 4){
               echo $instAdmin->editar_admin_controlador();
            }
            
            if (isset($_POST['option'])&& $_POST['option']== 5){
                $data = $instAdmin->editar_capturista_controlador();
            }

            if (isset($_POST['option'])&& $_POST['option']== 6){
               $data = $instAdmin->editar_pass_controlador();
            }

            print json_encode($data, JSON_UNESCAPED_UNICODE);

    } else{
        session_start();
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
    }