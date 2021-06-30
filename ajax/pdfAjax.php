<?php

    $peticionAjax=true;
    require_once "../core/configGeneral.php";

    $_POST= json_decode(file_get_contents("php://input"), true);

    if(isset($_POST['option'])){
        
        require_once "../controladores/pdfControlador.php";
        $instPdf= new pdf_controlador();

            if (isset($_POST['option'])&& $_POST['option']== 1){
                echo $instPdf->crear_pdf();
            }
    } else{
        session_start();
        session_destroy();
        echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
    }