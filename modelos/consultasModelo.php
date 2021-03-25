<?php 
if ($peticionAjax) {
    require_once "../core/mainModel.php";
} else {
    require_once "./core/mainModel.php";
}

class consultasModelo extends mainModel{
    
    protected function consultaEmbarque2_modelo($id){
        $query=mainModel::conectar()->prepare("SELECT gastos_embarque.id_embarque AS id, gastos.nombre, 
        gastos_embarque.extra, gastos_embarque.cantidad FROM gastos_embarque INNER JOIN gastos ON gastos_embarque.id_gasto= gastos.id_gasto INNER JOIN embarque ON gastos_embarque.id_embarque=embarque.id WHERE embarque.id=$id AND gastos_embarque.cantidad>0 ORDER BY gastos_embarque.extra DESC");
        $query->execute();
        return $query->fetchAll(PDO::FETCH_ASSOC);
        
    }
    /**Consulta por rango de embarques */
    protected function consultaRangoE($id, $id2){
        $query=mainModel::conectar()->prepare("SELECT gastos_embarque.id_embarque as id, gastos.nombre,gastos_embarque.extra ,gastos_embarque.cantidad FROM gastos_embarque INNER join gastos on gastos_embarque.id_gasto=gastos.id_gasto where gastos_embarque.id_embarque BETWEEN $id and $id2 AND gastos_embarque.cantidad>0 order by gastos_embarque.id_embarque ASC, gastos_embarque.extra DESC");
        $query->execute();
        return $query->fetchAll(PDO::FETCH_ASSOC);
        
    }


  /*Consulta embarque por rango de fechas */
  protected function consultaRango_modelo($fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT id, fecha_inicio, fecha_fin, cant_bolsas_embarque as cant, total_gastos from embarque where embarque.fecha_inicio
     BETWEEN '$fecha1' and '$fecha2'");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
    protected function consultaProductor_modelo($fecha1p, $fecha2p){
        $query= mainModel::conectar()->prepare("SELECT fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg, round(sum(productor_fruta.peso*fruta.pago-IFNULL(prestamos.abono_fungicida+prestamos.abono_fertilizante+prestamos.abono_prestamo,0)),2) as total FROM fruta inner join productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta LEFT JOIN prestamos on fruta.id= prestamos.id_fruta where productor_fruta.fecha_compra BETWEEN '$fecha1p' and '$fecha2p' GROUP by fruta.id_productores order by fruta.id_productores ASC");
        $query->execute();
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }
    protected function consultaProductorDetalle_modelo($idEmb, $idProd){
        $query=mainModel::conectar()->prepare("SELECT fruta.id_embarque as embarque, fruta.id_productores as id, 
        CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, fruta.peso_kg as kg, fruta.fecha_compra, fruta.pago, fruta.pago*fruta.peso_kg as total 
        from fruta
            INNER JOIN productores on fruta.id_productores=productores.id
            where fruta.id_embarque=$idEmb and fruta.id_productores=$idProd");
        $query->execute();
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }

    protected function consultaGeneral_modelo($fecha1g, $fecha2g){
        $query= mainModel::conectar()->prepare("SELECT  embarque.id, embarque.fecha_inicio, embarque.fecha_fin, gastos.nombre, gastos_embarque.extra, gastos_embarque.cantidad FROM embarque INNER JOIN gastos_embarque ON embarque.id=gastos_embarque.id_embarque INNER JOIN gastos ON gastos_embarque.id_gasto= gastos.id_gasto WHERE embarque.fecha_inicio BETWEEN '$fecha1g' AND '$fecha2g' AND gastos_embarque.cantidad>0");
        $query->execute();
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }
    protected function total_modelo($fecha1g, $fecha2g){

     $query= mainModel::conectar()->prepare("SELECT  SUM( gastos_embarque.cantidad) as total_gastos 
         from gastos_embarque 
         INNER JOIN embarque on gastos_embarque.id_embarque=embarque.id
         where embarque.fecha_inicio BETWEEN '$fecha1g' and '$fecha2g'");
     $query->execute();
     return $query->fetchAll(PDO::FETCH_ASSOC);
 }
    //Consulta gráficas

    //Grafica general
 protected function datosY_modelo($fecha1g, $fecha2g){
    $query=mainModel::conectar()->prepare("SELECT sum(gastos_embarque.cantidad) as cantidad from gastos_embarque
    inner join embarque on gastos_embarque.id_embarque=embarque.id
    where embarque.fecha_inicio BETWEEN  '$fecha1g' and '$fecha2g'
    GROUP BY embarque.fecha_inicio
    ORDER BY embarque.fecha_inicio asc");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
protected function datosX_modelo($fecha1g, $fecha2g){
    $query=mainModel::conectar()->prepare("SELECT embarque.fecha_inicio as fecha from embarque
    INNER join gastos_embarque on embarque.id=gastos_embarque.id_embarque
    where embarque.fecha_inicio BETWEEN  '$fecha1g' and '$fecha2g'
     GROUP BY embarque.fecha_inicio
    ORDER BY embarque.fecha_inicio asc");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
    //Grafica Productor
protected function datosYProd_modelo($fecha1p, $fecha2p){
    $query=mainModel::conectar()->prepare("SELECT ROUND(SUM(productor_fruta.peso),2) as total FROM fruta INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where productor_fruta.fecha_compra BETWEEN '$fecha1p' and '$fecha2p' GROUP by fruta.id_productores order by fruta.id_productores ASC");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
protected function datosXProd_modelo($fecha1p, $fecha2p){
    $query=mainModel::conectar()->prepare("SELECT DISTINCT id_productores, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as id from fruta 
    INNER JOIN productores on fruta.id_productores=productores.id 
    INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta 
    where productor_fruta.fecha_compra BETWEEN '$fecha1p' and '$fecha2p' order by id_productores ASC");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}

      //Grafica embarque bolsas
protected function datosYEmb1_modelo($fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT cant_bolsas_embarque as cantidad from embarque 
        where fecha_inicio BETWEEN '$fecha1' and '$fecha2' order by fecha_inicio");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);

}

protected function datosXEmb1_modelo($fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT id from embarque 
        where fecha_inicio BETWEEN '$fecha1' and '$fecha2' order by fecha_inicio");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}

    //Grafica embarque gastos

protected function datosYEmb2_modelo($fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT  total_gastos as gastos from embarque 
        where fecha_inicio BETWEEN '$fecha1' and '$fecha2' order by fecha_inicio");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
//---------------------Consultas extras 

//consulta por productor individual (rendimiento de productor por rango de fecha)

protected function rendimientoRango_modelo($idProd, $fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT fruta.id_embarque as embarque,fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, round(sum( productor_fruta.peso),2 )as peso, productor_fruta.fecha_compra as fecha_compra from fruta inner join productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where fruta.id_productores=$idProd and productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2' GROUP BY fruta.id_productores order by fruta.id_embarque asc");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
    //Grafica datos en y (peso)
protected function rendimientoRangoY_modelo($idProd,$fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT round( fruta.peso_kg,2) as peso from fruta 
    INNER join productor_fruta on fruta.id=productor_fruta.id_fruta
    WHERE fruta.id_productores=$idProd and productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2'
    GROUP BY fruta.id_embarque, fruta.id_productores");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}

//Grafica datos x (id embarque)    
protected function rendimientoRangoX_modelo($idProd, $fecha1, $fecha2){
    $query=mainModel::conectar()->prepare("SELECT fruta.id_embarque as fecha from fruta
    INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
    INNER JOIN productores on fruta.id_productores=productores.id
    WHERE fruta.id_productores=$idProd and productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2'
    GROUP BY fruta.id_embarque, fruta.id_productores");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}


//consulta por productor individual (rendimiento de productor historial completo)}


protected function rendimientoHistorial_modelo($idProd){
    $query=mainModel::conectar()->prepare("SELECT embarque.id, IFNULL( concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m),
     (SELECT concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m)
      FROM productores where productores.id=$idProd LIMIT 1)) as nombre, IFNULL(round(fruta.peso_kg,2),0) as peso,
       IFNULL(round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2),0) as rend from fruta
        INNER JOIN productores on fruta.id_productores=productores.id
         RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores=$idProd order by embarque.id");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}

//Grafica historial datos en y (peso)
protected function rendimientoHistorialY_modelo($idProd){
    $query=mainModel::conectar()->prepare("SELECT embarque.id, IFNULL(round(fruta.peso_kg,2),0) as peso from fruta 
    RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores= $idProd order by embarque.id");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}

//Grafica de rendimiento de productor
protected function rendimientoPY_modelo($idProd){
    $query=mainModel::conectar()->prepare("SELECT IFNULL(round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2),0) as rend 
    from fruta
     RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores=$idProd order by embarque.id");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
//Grafica historial datos en x (id embarques)
protected function rendimientoHistorialX_modelo($idProd){
    $query=mainModel::conectar()->prepare("SELECT embarque.id as embarque from embarque order by id asc");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
}
 
//consulta por productor individual (rendimiento de productores )
protected function rendimientoEmbarque_modelo($idEmb){
    $query=mainModel::conectar()->prepare("SELECT fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, SUM(fruta.peso_kg) as kg, fruta.fecha_compra from fruta
        INNER JOIN productores on fruta.id_productores=productores.id
        where fruta.id_embarque=$idEmb
        GROUP by fruta.id_productores
        ORDER by fruta.id_embarque");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
} 
//Grafica rendimiento en embarque datos en y (peso)
protected function rendimientoEmbarqueY_modelo($idEmb){
    $query=mainModel::conectar()->prepare("SELECT fruta.peso_kg as peso from fruta where fruta.id_embarque=$idEmb order by fruta.fecha_compra");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
} 
//Grafica rendimiento en embarque datos en x (id de productores)
protected function rendimientoEmbarqueX_modelo($idEmb){
    $query=mainModel::conectar()->prepare("SELECT id_productores as id from fruta  where fruta.id_embarque=$idEmb order by fecha_compra");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);
} 

protected function rendimientoE(){
    $query=mainModel::conectar()->prepare("SELECT e.id, e.fecha_inicio, e.fecha_fin, e.cant_bolsas_embarque bolsas, e.perdida, e.bolsas_exitentes, e.bolsas_toston, e.total_gastos , e.toneladas, ROUND(e.cant_bolsas_embarque / ROUND(e.toneladas, 2), 2) rendimiento FROM embarque e WHERE ROUND(e.cant_bolsas_embarque / ROUND(e.toneladas, 2), 2)>=20");
    $query->execute();
    return $query->fetchAll(PDO::FETCH_ASSOC);

}

}