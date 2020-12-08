<?php

$peticionAjax=true;
require_once "../core/configGeneral.php";

$_POST= json_decode(file_get_contents("php://input"), true);

if(isset($_POST['option'])){

    require_once "../controladores/consultasControlador.php";
    $instGasto= new consultasControlador();

    if (isset($_POST['option'])&& $_POST['option']== 1){
        $data= $instGasto->totalRangoEmbarque();
    }

    if (isset($_POST['option'])&& $_POST['option']== 2){
        $data=$instGasto->consultaEmbarque2_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 3){
        $data=$instGasto->consultaRango_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 4){
        $data=$instGasto->consultaProductor_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 5){
        $data=$instGasto->consultaGeneral_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 6){
        $data=$instGasto->total();
    }

    //Datos X Y de la grafica general
    if (isset($_POST['option'])&& $_POST['option']== 7){
        $data=$instGasto->datosY_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 8){
        $data=$instGasto->datosX_controlador();
    }

    //Datos grafica productor
    if (isset($_POST['option'])&& $_POST['option']== 9){
        $data=$instGasto->datosYProd_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 10){
        $data=$instGasto->datosXProd_controlador();
    }

    //Datos1 grafica embarque
    if (isset($_POST['option'])&& $_POST['option']== 11){
        $data=$instGasto->datosYEmb1_controlador();
    }

    if (isset($_POST['option'])&& $_POST['option']== 12){
        $data=$instGasto->datosXEmb1_controlador();
    }

    //Datos1 grafica embarque
    if (isset($_POST['option'])&& $_POST['option']== 13){
        $data=$instGasto->datosYEmb2_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==14){
        $data=$instGasto->rendimientoRango_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==15){
        $data=$instGasto->rendimientoHistorial_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==16){
        $data=$instGasto->rendimientoEmbarque_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==17){
        $data=$instGasto->rendimientoRangoY_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==18){
        $data=$instGasto->rendimientoRangoX_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==19){
        $data=$instGasto->rendimientoHistorialY_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==20){
        $data=$instGasto->rendimientoHistorialX_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==21){
        $data=$instGasto->rendimientoEmbarqueY_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==22){
        $data=$instGasto->rendimientoEmbarqueX_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==23){
        $data=$instGasto->rendimientoE_c();
    }

    //Ver detalles productores rango de fechas
    if (isset($_POST['option']) && $_POST['option']==24){
        $data=$instGasto->consultaProductorDetalle_controlador();
    }

    if (isset($_POST['option']) && $_POST['option']==26){
        $data=$instGasto->rendimientoPY_controlador();
    }

    /* Datos para generar reportes PDF */
    if (isset($_POST['option']) && $_POST['option']==25){
        $data=$instGasto->reportesData();
    }

      //Trabajadores
      if (isset($_POST['option']) && $_POST['option']==27){
        $data=$instGasto->listarPealadorBolsa();
    }
    if (isset($_POST['option']) && $_POST['option']==28){
        $data=$instGasto->listarPeladorBolsaFecha();
    }
    //Bolseros pagos
    if (isset($_POST['option']) && $_POST['option']==29){
        $data=$instGasto->listarBolseroPagosEmb();
    }
    if (isset($_POST['option']) && $_POST['option']==30){
        $data=$instGasto->listarBolserosPagosFecha();
    }
 
     //Aguinaldos
     if (isset($_POST['option']) && $_POST['option']==31){
        $data=$instGasto->aguinaldoFecha();
    }
    if (isset($_POST['option']) && $_POST['option']==32){
        $data=$instGasto->aguinaldoEmb();
    }
    //Rendimiento por fecha
    if (isset($_POST['option']) && $_POST['option']==33){
        $data=$instGasto->rendfecha();
    }
     //Aguinaldos
     if (isset($_POST['option']) && $_POST['option']==34){
        $data=$instGasto->abonosFecha();
    }
    if (isset($_POST['option']) && $_POST['option']==35){
        $data=$instGasto->abonosEmbarque();
    }
     //Pago bolseros
     if (isset($_POST['option']) && $_POST['option']==36){
        $data=$instGasto->listarPagoPeladorEmb();
    }
    if (isset($_POST['option']) && $_POST['option']==37){
        $data=$instGasto->listarPagoPeladorFech();
    }

    //Datos en X y Y de bolsas peladores
    if (isset($_POST['option']) && $_POST['option']==38){
        $data=$instGasto->listaYBP();
    }
    if (isset($_POST['option']) && $_POST['option']==39){
        $data=$instGasto->listaXBP();
    }

    //Datos en X y Y de aguinaldo
    if (isset($_POST['option']) && $_POST['option']==40){
        $data=$instGasto->listaYAguinaldo();
    }
    if (isset($_POST['option']) && $_POST['option']==41){
        $data=$instGasto->listaXAguinaldo();
    }

    //Datos en X y Y de pago bolseros
    if (isset($_POST['option']) && $_POST['option']==42){
        $data=$instGasto->listaYPB();
    }
    if (isset($_POST['option']) && $_POST['option']==43){
        $data=$instGasto->listaXPB();
    }

    //Datos en X y Y de pago peladores
    if (isset($_POST['option']) && $_POST['option']==44){
        $data=$instGasto->listaYPP();
    }
    if (isset($_POST['option']) && $_POST['option']==45){
        $data=$instGasto->listaXPP();
    }
    if (isset($_POST['option']) && $_POST['option']==46){
        $data=$instGasto->promedioFruta();
    }
    //Nombre de productor por id
    if (isset($_POST['option']) && $_POST['option']==47){
        $data=$instGasto->nombreProd();
    }
    print json_encode($data, JSON_UNESCAPED_UNICODE);
}else{
    session_start(['name'=>'PT']);
    session_destroy();
    echo '<script>window.location.href="'.SERVERURL.'login/"</script>';
}