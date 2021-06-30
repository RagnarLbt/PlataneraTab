<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
    }

class bancoModelo extends mainModel{
    //Funciones protegidas

    protected function listaDolares_modelo($id){
        $sql=mainModel::conectar()->prepare("SELECT dolares.* FROM `cuenta_dolares`, dolares WHERE dolares.id_cuentaD=cuenta_dolares.id AND cuenta_dolares.id_emb=$id");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function listaPesos_modelo($id){
        $sql=mainModel::conectar()->prepare("SELECT pesos.* FROM `cuenta_pesos`, pesos WHERE pesos.id_cuenta=cuenta_pesos.id AND cuenta_pesos.id_emb=$id");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function listaBolsas_modelo($id){
        $sql=mainModel::conectar()->prepare("SELECT bolsas.* FROM `cuenta_bolsas`, bolsas WHERE bolsas.id_cuenta=cuenta_bolsas.id AND cuenta_bolsas.idemb=$id");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function agregarDolares_modelo($id, $concepto, $ingreso, $egreso, $saldo){

        $query=mainModel::conectar()->prepare("call agregarCuentaD(:Id, :Concepto, :Ingreso, :Egreso, :Saldo)");
        $query->bindParam("Id", $id);
        $query->bindParam("Concepto", $concepto);
        $query->bindParam("Ingreso", $ingreso);
        $query->bindParam("Egreso", $egreso);
        $query->bindParam("Saldo", $saldo);
        $query->execute();
        return $query;
    }

    protected function total_modelo($idEmb){
        $sql=mainModel::conectar()->prepare("SELECT total_ingreso as ingreso, total_egreso as egreso, total_saldo as saldo from cuenta_dolares where id_emb=$idEmb");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function totalPesos_modelo($idEmb){
        $sql=mainModel::conectar()->prepare("SELECT total_ingreso as ingreso, total_egreso as egreso, total_saldo as saldo from cuenta_pesos where id_emb=$idEmb");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function totalBolsas_modelo($idEmb){
        $sql=mainModel::conectar()->prepare("SELECT ingreso, egreso, saldo from cuenta_bolsas where idemb=$idEmb");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function resumen_modelo($idEm){
        $sql=mainModel::conectar()->prepare("SELECT embarque.total_gastos as gasto, CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$idEm) as decimal(10,2)) as taza, cast(embarque.total_gastos/CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$idEm) as decimal(10,4)) as decimal(10,2)) as gastoD, (embarque.cant_bolsas_embarque) as bolsas, cast(embarque.total_gastos/embarque.cant_bolsas_embarque as decimal(10,2)) as costoP, cast( ( (embarque.total_gastos)/ ( CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$idEm) as decimal(10,4)) ) ) / (embarque.cant_bolsas_embarque) as decimal(10,2)) as costoD from cuenta_dolares INNER join dolares on cuenta_dolares.id=dolares.id_cuentaD INNER JOIN embarque on embarque.id=cuenta_dolares.id_emb where cuenta_dolares.id_emb=$idEm");
        $sql->execute();
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

}