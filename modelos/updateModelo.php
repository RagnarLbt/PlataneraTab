<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
    }
    
    class updateModelo extends mainModel{
        
        protected function listaEmb_modelo(){
            $sql=mainModel::conectar()->prepare("SELECT id FROM `embarque` WHERE cuentas=1 ORDER BY id DESC LIMIT 1");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaEmbActivos_modelo(){
            $sql=mainModel::conectar()->prepare("SELECT id FROM embarque where fecha_fin='0000-00-00'");
            $sql->execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }
        
        protected function listaProd_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT fruta.id as idF, fruta.id_productores as id, IFNULL(prestamos.id,0) as idPres, concat(productores.nombre,' ', productores.Ap_p,' ', productores.Ap_m) as nombre, fruta.peso_kg as peso, fruta.pago as compra, round(fruta.saldo_abono, 2) as total1, IFNULL(prestamos.fungicida, 0) AS fungicida, IFNULL(prestamos.fertilizante, 0) AS fertilizante, IFNULL(prestamos.prestamo, 0) as prestamo, IFNULL(round(prestamos.fungicida+prestamos.fertilizante+prestamos.prestamo, 2), 0) as total2, IFNULL(round(prestamos.abono_fungicida, 2),0) as abono_fun, IFNULL(round(prestamos.abono_fertilizante, 2),0) as abono_fer, IFNULL(round( prestamos.abono_prestamo, 2),0) as abono_prestamo, round( (fruta.saldo_abono) - ( IFNULL(prestamos.abono_fungicida, 0) + IFNULL(prestamos.abono_fertilizante, 0) + IFNULL(prestamos.abono_prestamo, 0) ), 2) as aPagar, IFNULL(round(prestamos.saldo_fungicida,2),0) as fun, IFNULL(round(prestamos.saldo_fertilizante,2),0) as fer, IFNULL(round(prestamos.saldo_prestamo,2),0) as pres, IFNULL(prestamos.no_pagos_fungicida, 0) as noPFun, IFNULL(prestamos.no_pagos_fertilizante, 0) as noPFer, IFNULL(prestamos.no_pagos_prestamo, 0) as noPPre  from fruta  LEFT join prestamos on fruta.id=prestamos.id_fruta INNER JOIN productores on fruta.id_productores=productores.id where fruta.id_embarque=$idE GROUP BY fruta.id_embarque, fruta.id_productores");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function totalesProd_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT ROUND(SUM(fruta.peso_kg),2) as peso, round(sum(fruta.saldo_abono)/sum(fruta.peso_kg),2) as compra, round(sum(fruta.saldo_abono), 2) as total1, IFNULL(SUM(prestamos.fungicida), 0) AS fungicida, IFNULL(SUM(prestamos.fertilizante), 0) AS fertilizante, IFNULL(SUM(prestamos.prestamo), 0) as prestamo, IFNULL(round( SUM(prestamos.fungicida)+SUM(prestamos.fertilizante)+SUM(prestamos.prestamo), 2),0) as total2, IFNULL(round(sum(prestamos.abono_fungicida), 2),0) as abono_fun, IFNULL(round(sum(prestamos.abono_fertilizante), 2),0) as abono_fer, IFNULL(round( SUM(prestamos.abono_prestamo), 2),0) as abono_prestamo, ROUND(IFNULL(SUM(fruta.saldo_abono),0) - (IFNULL(sum(prestamos.abono_fungicida),0) + IFNULL(sum(prestamos.abono_fertilizante),0) + IFNULL(SUM(prestamos.abono_prestamo),0) ),2) as aPagar, IFNULL(round(SUM(prestamos.saldo_fungicida),2),0) as fun, IFNULL(round(SUM(prestamos.saldo_fertilizante),2),0) as fer, IFNULL(round(SUM(prestamos.saldo_prestamo),2),0) as pres from fruta LEFT join prestamos on fruta.id=prestamos.id_fruta INNER JOIN productores on fruta.id_productores=productores.id where fruta.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function updateProd($idE, $precioProd, $cantidadProd,  $insumoProd,  $prestamoProd,  $abono_insumo,  $abono_prestamo ,  $idProd){
            $query=mainModel::conectar()->prepare("call updateProd($idE, $precioProd, $cantidadProd,  $insumoProd,  $prestamoProd,  $abono_insumo,  $abono_prestamo ,  $idProd)");
           
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaToston_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT bolsas_toston.id as idPlanilla, bolsas_toston.id_planilla as id, concat(planilla_toston.nombre, ' ', planilla_toston.ap_p, ' ', planilla_toston.ap_m)
               as nombre, bolsas_toston.fecha, bolsas_toston.diaUno, bolsas_toston.diaDos, bolsas_toston.diaTres,
               bolsas_toston.diaCuatro, bolsas_toston.diaCinco, bolsas_toston.pago from 
               bolsas_toston INNER JOIN planilla_toston on bolsas_toston.id_planilla=planilla_toston.id WHERE bolsas_toston.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function totalToston_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT  sum(bolsas_toston.pago) as total from bolsas_toston where bolsas_toston.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function updateToston_modelo($idE, $idP, $a, $b, $c, $d, $e){
            $sql=mainModel::conectar()->prepare("call update_planilla(1, $idE, $a,$b,$c,$d,$e,0,$idP,0)");
            $sql-> execute();
            return $sql;
        }
        
        protected function listaBolserosExtra_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT bolsero_extra.id, concat(bolsero_extra.nombre, ' ', bolsero_extra.apellidos) as nombre, bolsero_extra.pago from bolsero_extra where bolsero_extra.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaBolseros_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT bolsas_bolsero.id_bolsero as id,
               concat(bolseros.nombre,' ', bolseros.Ap_p,' ', bolseros.Ap_m) as nombre,
               bolsas_bolsero.diaUno, bolsas_bolsero.diaDos, bolsas_bolsero.diaTres,
               bolsas_bolsero.diaCuatro, bolsas_bolsero.diaCinco, bolsas_bolsero.cantidad_bolsas_bol as cantidad,
               bolsas_bolsero.pago_bol as pago FROM bolsas_bolsero 
               INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id where bolsas_bolsero.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function totalBolseros_modelo($idE){
            $sql=mainModel::conectar()->prepare("SELECT round(sum(bolsas_bolsero.pago_bol),2) as total from bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id where bolsas_bolsero.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function updateBolseros_modelo($idE, $idBolsero,$a, $b, $c, $d, $e){
            $sql=mainModel::conectar()->prepare("call update_bolseros(1, $idE, $a, $b, $c, $d, $e, $idBolsero)");
            $sql->execute();
            return $sql;
        }

        protected function updateBolserosExtra_modelo($idE, $idBolseroExtra, $pagoBolseroExtra){
            $sql=mainModel::conectar()->prepare("UPDATE bolsero_extra set bolsero_extra.pago=$pagoBolseroExtra
            where bolsero_extra.id=$idBolseroExtra and bolsero_extra.id_embarque=$idE");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

    };