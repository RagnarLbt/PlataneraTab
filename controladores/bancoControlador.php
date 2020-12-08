<?php 
	if ($peticionAjax) {
		require_once "../modelos/bancoModelo.php";
	} else {
		require_once "./modelos/bancoModelo.php";
    }

class bancoControlador extends bancoModelo {
    //funciones públicas

    public function listaDolares_controlador(){
        $id=$_POST['embarque'];
        $sql=bancoModelo::listaDolares_modelo($id);
        return $sql;
    }

    public function listaPesos_controlador(){
        $id=$_POST['embarque'];
        $sql=bancoModelo::listaPesos_modelo($id);
        return $sql;
    }

    public function listaBolsas_controlador(){
        $id=$_POST['embarque'];
        $sql=bancoModelo::listaBolsas_modelo($id);
        return $sql;
    }

    public function agregarDolares(){
        $id=$_POST["id"];
        $concepto=strtoupper($_POST["concepto"]);
        $ingreso=$_POST["ingreso"];
        $egreso=$_POST["egreso"];
        $saldo=0;
        $taza=$_POST['taza'];

        $sql=mainModel::ejecutar_consulta_simple("CALL addDolares('$concepto', $id, $ingreso, $egreso, $taza)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }        
    }

    public function agregarPesos(){
        $id=$_POST["id"];
        $concepto=strtoupper($_POST["concepto"]);
        $ingreso=$_POST["ingreso"];
        $egreso=$_POST["egreso"];
        $saldo=0;

        $sql=mainModel::ejecutar_consulta_simple("CALL addPesos('$concepto', $ingreso, $egreso, $id)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }

    }

    public function agregarBolsas(){
        $id=$_POST["id"];
        $concepto=$_POST["concepto"];
        $ingreso=$_POST["ingreso"];
        $egreso=$_POST["egreso"];
        $saldo=0;

        $sql=mainModel::ejecutar_consulta_simple("CALL addBolsas($id, '$concepto', $egreso)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }
    }

    public function total_controlador(){
        $idEmb=$_POST["id"];
        $sql=bancoModelo::total_modelo($idEmb);
        return $sql;
    }

    public function totalPesos_controlador(){
        $idEmb=$_POST["id"];
        $sql=bancoModelo::totalPesos_modelo($idEmb);
        return $sql;    
    }

    public function totalBolsas_controlador(){
        $idEmb=$_POST["id"];
        $sql=bancoModelo::totalBolsas_modelo($idEmb);
        return $sql;
    }

    public function resumen_controlador(){
        $idEm=$_POST["id"];
        $sql=bancoModelo::resumen_modelo($idEm);
        return $sql;
    }
    
    public function cerrarCuenta_controlador(){
        $id_e=$_POST['id'];

        $sql=mainModel::ejecutar_consulta_simple("CALL cerraCuenta ($id_e)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }
    }

    public function actualizarBanco(){
        $opc=$_POST['dato'];
        $idTabla=$_POST['id'];
        $idCuenta=$_POST['id_C'];
        $concepto=strtoupper($_POST['concepto']);
        $ingreso=$_POST['ingre'];
        $egreso=$_POST['egre'];
        $ingAnterior=$_POST['ingAnt'];
        $egrAnterior=$_POST['egrAnt'];
        $saldoAnterior=$_POST['saldo'];
        $tazaCambio=$_POST['taza'];
        $embarque=$_POST['embarque'];

        $sql=mainModel::ejecutar_consulta_simple("CALL actCuentas($opc, $idTabla, $idCuenta, '$concepto', $ingreso, $egreso, $tazaCambio, $ingAnterior, $egrAnterior, $saldoAnterior, $embarque)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }
    }

    public function deleteBancos(){
        $opc=$_POST['dato'];
        $idTabla=$_POST['id'];
        $idCuenta=$_POST['id_C'];
        $ingAnterior=$_POST['ingAnt'];
        $egrAnterior=$_POST['egrAnt'];
        $saldoAnterior=$_POST['saldo'];
        $tazaCambio=$_POST['taza'];

        $sql=mainModel::ejecutar_consulta_simple("CALL delCuentas($opc, $idTabla, $idCuenta, $ingAnterior, $egrAnterior, $tazaCambio)");

        if($sql->rowCount()>=1){
            return "OK";
        }else{
            return $sql;
        }
    }

}