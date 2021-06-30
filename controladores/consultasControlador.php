<?php
if ($peticionAjax) {
  require_once "../modelos/consultasModelo.php";
} else {
  require_once "./modelos/consultasModelo.php";
}

class consultasControlador extends consultasModelo{

    public function totalRangoEmbarque(){
        $id = $_POST['id'];
        $id2 = $_POST['id2'];
        
        if($id!=0 && $id2!=0){
            $sql=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad)as total_gastos from gastos_embarque where gastos_embarque.id_embarque BETWEEN $id and $id2");
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }else {
            $sql=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad) as total_gastos from gastos_embarque where id_embarque=$id");
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }
    }
    public function promedioFruta(){
        $id=$_POST['idProd2'];
        $sql=mainModel::ejecutar_consulta_simple("SELECT round( SUM(productor_fruta.peso)/count(embarque.id),2) as promedio
         FROM fruta INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta 
         RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores=$id");
        return $sql->fetchAll(PDO::FETCH_ASSOC);
         
         
    }
    public function nombreProd(){
        $id=$_POST['id'];
        $sql=mainModel::ejecutar_consulta_simple("SELECT concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre from productores
        WHERE productores.id=$id");
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

   //valor maximo de fruta  

    public function maxProd(){
        $sql=mainModel::ejecutar_consulta_simple("SELECT max(peso_kg) as m from fruta");
        return $sql->fetchAll(PDO::FETCH_ASSOC);
    }

    public function valorMaxProdRangodeFecha(){
        $fecha1=$_POST['fecha_uno'];
        $fecha2=$_POST['fecha_dos'];
        $sql=mainModel::ejecutar_consulta_simple("SELECT max(peso_kg) as m from fruta INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta WHERE productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2'");
        return $sql->fetchAll(PDO::FETCH_ASSOC);   
    }

    public function consultaEmbarque2_controlador(){
        $id = $_POST['id'];
        $id2 = $_POST['id2'];
       
       if($id!=0 && $id2!=0){
            $sql=consultasModelo::consultaRangoE($id, $id2);
            return $sql; 
       }else {
            $sql=consultasModelo::consultaEmbarque2_modelo($id);
            return $sql; 
       }
         
    }

    /**Consulta embarque por rango de fechas  */
    public function consultaRango_controlador(){
        $fecha1 = $_POST['fecha1'];
        $fecha2 = $_POST['fecha2'];
        $sql= consultasModelo::consultaRango_modelo($fecha1, $fecha2);
        return $sql; 
    }

    public function consultaProductor_controlador(){
        $fecha1p=$_POST['fecha1p'];
        $fecha2p=$_POST['fecha2p'];
        $sql=consultasModelo::consultaProductor_modelo($fecha1p, $fecha2p);
        return  $sql;
    }

    public function consultaProductorDetalle_controlador(){
        $idEmb=$_POST['idE'];
        $idProd=$_POST['idP'];
        $sql=consultasModelo::consultaProductorDetalle_modelo($idEmb, $idProd);
        $html= '<div class="col-sm-12"><table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm" ><thead><tr class="bg-dark text-light"><th class="text-center">Embarque</th><th class="text-center">Id Productor</th><th class="text-center">Nombre</th><th class="text-center">Kilos</th><th class="text-center">Fecha compra</th><th class="text-center">Pago por kg</th><th class="text-center">Pago total</th></tr></thead><tbody  class="table" id="tablass">';
        foreach($sql as $fila){

         $html.='<tr ><td>'.$fila["embarque"].'</td><td>'.$fila["id"].'</td><td>'.$fila["nombre"].'</td><td>'.$fila["kg"].'</td><td>'.$fila["fecha_compra"].'</td><td>$ '.$fila["pago"].'</td><td>$'.$fila["total"].'</td></tr>';
     };
     $html.='</tbody></table></div>';

     return $html;
    }

    public function consultaGeneral_controlador(){
        $fecha1g=$_POST['fecha1g'];
        $fecha2g=$_POST['fecha2g'];
        $sql=consultasModelo::consultaGeneral_modelo($fecha1g, $fecha2g);
        return  $sql;
    }

    public function total(){
        $fecha1g=$_POST['fecha1g'];
        $fecha2g=$_POST['fecha2g'];
        $sql=consultasModelo::total_modelo($fecha1g, $fecha2g);
        return $sql;
    }

    public function datosY_controlador(){
        $fecha1g=$_POST['fecha1g'];
        $fecha2g=$_POST['fecha2g'];
        $sql=consultasModelo::datosY_modelo($fecha1g, $fecha2g);
        return $sql;
    }

    public function datosX_controlador(){
        $fecha1g=$_POST['fecha1g'];
        $fecha2g=$_POST['fecha2g'];
        $sql=consultasModelo::datosX_modelo($fecha1g, $fecha2g);
        return $sql; 
    }
    //Datos grafica productor
    public function datosYProd_controlador(){
        $fecha1p=$_POST['fecha1p'];
        $fecha2p=$_POST['fecha2p'];
        $sql=consultasModelo::datosYProd_modelo($fecha1p, $fecha2p);
        return  $sql;
    }

    public function datosXProd_controlador(){
        $fecha1p=$_POST['fecha1p'];
        $fecha2p=$_POST['fecha2p'];
        $sql=consultasModelo::datosXProd_modelo($fecha1p, $fecha2p);
        return  $sql;
    }
    
    //Grafica embarque datos bolsas
    public function datosYEmb1_controlador(){
        $fecha1 = $_POST['fecha1'];
        $fecha2 = $_POST['fecha2'];
        $sql= consultasModelo::datosYEmb1_modelo($fecha1, $fecha2);
        return $sql; 
    }

    public function datosXEmb1_controlador(){
        $fecha1 = $_POST['fecha1'];
        $fecha2 = $_POST['fecha2'];
        $sql= consultasModelo::datosXEmb1_modelo($fecha1, $fecha2);
        return $sql; 
    }

    //Grafica de embarque datos gastos
    public function datosYEmb2_controlador(){
        $fecha1 = $_POST['fecha1'];
        $fecha2 = $_POST['fecha2'];
        $sql= consultasModelo::datosYEmb2_modelo($fecha1, $fecha2);
        return $sql; 
    }
//Consultas extras 
    public function rendimientoRango_controlador(){
        $idProd=$_POST['idProd'];
        $fecha1p = $_POST['fecha1p2'];
        $fecha2p = $_POST['fecha2p2'];
        $sql=consultasModelo::rendimientoRango_modelo($idProd, $fecha1p, $fecha2p);
        return $sql;
    }
    //Grafica datos en y (peso)
    public function rendimientoRangoY_controlador(){
        $idProd=$_POST['idProd'];
        $fecha1p = $_POST['fecha1p2'];
        $fecha2p = $_POST['fecha2p2'];
        $sql=consultasModelo::rendimientoRangoY_modelo($idProd, $fecha1p, $fecha2p);
        return $sql;
    }
    //Grafica datos en x (id embarque)
    public function rendimientoRangoX_controlador(){
        $idProd=$_POST['idProd'];
        $fecha1p = $_POST['fecha1p2'];
        $fecha2p = $_POST['fecha2p2'];
        $sql=consultasModelo::rendimientoRangoX_modelo($idProd, $fecha1p, $fecha2p);
        return $sql;
    }
    //==================
    public function rendimientoHistorial_controlador(){

        $idProd = $_POST['idProd2'];
        $sql=consultasModelo::rendimientoHistorial_modelo($idProd);
        return $sql;
    }
    //Grafica datos en y (peso)
    public function rendimientoHistorialY_controlador(){

        $idProd = $_POST['idProd2'];
        $sql=consultasModelo::rendimientoHistorialY_modelo($idProd);
        return $sql;
    }
    //Rendimiento de productor Y
    public function rendimientoPY_controlador(){

        $idProd = $_POST['idProd2'];
        $sql=consultasModelo::rendimientoPY_modelo($idProd);
        return $sql;
    }
    //Grafica datos en x (id embarque)
    public function rendimientoHistorialX_controlador(){
        $idProd = $_POST['idProd2'];
        $sql=consultasModelo::rendimientoHistorialX_modelo($idProd);
        return $sql;
    }

    
    /**Multi select */
    public function rendimientoEmbarque_controlador(){
        $idPro=$_POST['idPro'];
      
        $idEmb = $_POST['idEmb'];
        $idEmb2 = $_POST['idEmb2'];
       
          //-Todos los productores en un embarque
        if ($idPro[0]==9999 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg,  round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
            INNER JOIN productores on fruta.id_productores=productores.id
            where fruta.id_embarque=$idEmb
            GROUP by fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //-Todos los productores en un rango de embarque
        elseif($idPro[0]==9999 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, 
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg, 
             round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta INNER JOIN productores on fruta.id_productores=productores.id
              where fruta.id_embarque BETWEEN $idEmb AND $idEmb2   GROUP BY fruta.id_productores ORDER by  fruta.id_productores asc");

            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
       
        
       else if (count($idPro)==1 && $idEmb!=0 && $idEmb2==0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg,  round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
            INNER JOIN productores on fruta.id_productores=productores.id
            where fruta.id_embarque =$idEmb AND FRUTA.id_productores=$idPro[0]
            GROUP by fruta.id_productores");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
       
        //-Un productor en un rango de embarques
        else if(count($idPro)==1 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id, CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg,  round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend
             from fruta INNER JOIN productores on fruta.id_productores=productores.id
            where fruta.id_productores=$idPro[0] and fruta.id_embarque  BETWEEN $idEmb AND $idEmb2 
           GROUP by fruta.id_productores
            ORDER by fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
         //-Varios productores en un  embarque
         elseif(count($idPro)>1 && $idEmb!=0 && $idEmb2==0){
            $array = $idPro;
            $Prod = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg,  round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta 
            INNER JOIN productores on fruta.id_productores=productores.id 
            where fruta.id_productores in ($Prod) and fruta.id_embarque=$idEmb
            GROUP by fruta.id_productores, fruta.id_embarque ORDER by fruta.id_embarque
            ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //-Varios productores en un rango de embarques
        else if (count($idPro)>1 &&  $idEmb!=0 && $idEmb2!=0  ){
            $array = $idPro;
            $Prod = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(fruta.peso_kg),2) as kg,  round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta 
            INNER JOIN productores on fruta.id_productores=productores.id 
            where fruta.id_productores in ($Prod) and fruta.id_embarque between $idEmb and $idEmb2
            GROUP by fruta.id_productores ORDER by fruta.id_productores asc
            ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        
       
    
    }
     //============================================

    //Grafiica datos en Y (peso) RENDIMIENTO DE PRODUCTORES
    public function rendimientoEmbarqueY_controlador(){
        $op=$_POST['op'];
        if($op==1){ //entonces es por embarque
            $idPro = $_POST['idPro'];
            $idEmb = $_POST['idEmb'];
            $idEmb2 = $_POST['idEmb2'];
            
            //5.-Todos los productores en un embarque
            if ($idPro[0]==9999 && $idEmb!=0 && $idEmb2==0){
                $query=mainModel::ejecutar_consulta_simple("SELECT productores.id, productores.nombre, round(fruta.peso_kg, 2) as peso_kg, fruta.id_embarque FROM fruta, productores WHERE fruta.id_embarque=$idEmb AND productores.id=fruta.id_productores ORDER BY fruta.id_productores, fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //6.-Todos los productores en un rango de embarque
            else if($idPro[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta where fruta.id_embarque BETWEEN $idEmb and $idEmb2 ORDER BY fruta.id_productores, fruta.id_embarque"); return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //5.- Un productor en un embarque
            else if (count($idPro)==1 && $idEmb!=0 && $idEmb2==0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta WHERE fruta.id_productores=$idPro[0] and fruta.id_embarque=$idEmb");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }

            //3.-Un productor en un rango de embarques
            else if(count($idPro)==1 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta where fruta.id_productores=$idPro[0] and fruta.id_embarque BETWEEN $idEmb and $idEmb2 ORDER BY fruta.id_productores, fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //**4.-Varios productores en un embarque
            else if (count($idPro)>1 &&  $idEmb!=0 && $idEmb2==0  ){
                $array=$idPro;
                $Prod=implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id,round(fruta.peso_kg,2) as peso_kg from fruta
                    where fruta.id_embarque=$idEmb and fruta.id_productores in ($Prod) GROUP BY fruta.id_embarque, fruta.id_productores 
                    ORDER BY fruta.id_productores ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //**2.-Varios productores en un rango de embarques
            elseif(count($idPro)>1 && $idEmb!=0 && $idEmb2!=0){
                $array=$idPro;
                $Prod=implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta
                    where fruta.id_productores in ($Prod) and fruta.id_embarque between $idEmb and $idEmb2  
                    ORDER BY fruta.id_productores, fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
        }else if($op==2){//entonces es por fecha
                $idPro=$_POST["idPro"];
                $fecha1=$_POST["fech1"];
                $fecha2=$_POST["fech2"];
            
                //Todos los productores una fecha
                if($idPro[0]==9999 && $fecha1!="" && $fecha2==""){
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta where  productor_fruta.fecha_compra='$fecha1' GROUP BY fruta.id_embarque, fruta.id_productores");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Todos los productores rango de fecha
                elseif($idPro[0]==9999 && $fecha1!="" && $fecha2!=""){
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta where  productor_fruta.fecha_compra between '$fecha1' and '$fecha2' GROUP BY fruta.id_embarque, fruta.id_productores ORDER BY fruta.id_productores, fruta.id_embarque");
                    return $query->fetchAll(PDO::FETCH_ASSOC);

                }   
                //Un productor una fecha
                else if (count($idPro)==1 && $fecha1!="" && $fecha2==""){
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(fruta.peso_kg,2) as peso_kg from fruta INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta where  productor_fruta.fecha_compra='$fecha1' and fruta.id_productores=$idPro[0]");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Un productor rango de fechas
                else if (count($idPro)==1 && $fecha1!="" && $fecha2!="" ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(productor_fruta.peso,2) as peso_kg from fruta INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta where  productor_fruta.fecha_compra between '$fecha1' and '$fecha2' and fruta.id_productores=$idPro[0] GROUP BY fruta.id_embarque, fruta.id_productores order by fruta.id_productores asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Varios productores una fecha
                elseif(count($idPro)>1 && $fecha1!="" && $fecha2==""){
                    $array = $idPro;
                    $Pel = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(productor_fruta.peso,2) as peso_kg from fruta 
                    INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta
                    where  productor_fruta.fecha_compra='$fecha1' and fruta.id_productores in ($Pel) GROUP BY fruta.id_embarque, fruta.id_productores
                    order by fruta.id_productores asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }

                //Varios productores rango de fechas
                elseif(count($idPro)>1 && $fecha1!="" && $fecha2!=""){
                    $array = $idPro;
                    $Pel = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque, fruta.id_productores as id, round(sum(productor_fruta.peso),2) as peso_kg from fruta 
                    INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta
                    where  productor_fruta.fecha_compra between '$fecha1' and '$fecha2' and fruta.id_productores in ($Pel) GROUP BY fruta.id_embarque, fruta.id_productores ORDER BY fruta.id_productores, fruta.id_embarque asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);

                }
        }
    }
    //Grafica datos en x (id productores) RENDIMIENTO DE PRODUCTORES

    public function rendimientoEmbarqueX_controlador(){
        
        $op= $_POST['op'];
      
        if ($op==1){
            $idPro = $_POST['idPro'];
            $idEmb = $_POST['idEmb'];
            $idEmb2 = $_POST['idEmb2'];
            $resultado=[];
            //5.-Todos los productores en un embarque
            if ($idPro[0]==9999 && $idEmb!=0 && $idEmb2==0){
                for ($i=0; $i < 1; $i++) { 
                    $resultado[$i]=$idEmb;
                }
                return $resultado;
            }
            //6.-Todos los productores en un rango de embarque
            else if($idPro[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                for ($i=0; $i <= ($idEmb2-$idEmb); $i++) { 
                    $resultado[$i]=$idEmb+$i;
                }
                return $resultado;
            }
            //Un productor en un embarque
            else if (count($idPro)==1 && $idEmb!=0 && $idEmb2==0 ){
                for ($i=0; $i < 1; $i++) { 
                    $resultado[$i]=$idEmb;
                }
                return $resultado;
            }
        
            //3.-Un productor en un rango de embarques
            else if(count($idPro)==1 && $idEmb!=0 && $idEmb2!=0){
                for ($i=0; $i <= ($idEmb2-$idEmb); $i++) { 
                    $resultado[$i]=$idEmb+$i;
                }
                return $resultado;
            }
            //**4.-Varios productores en un rango de embarques
            else if (count($idPro)>1 &&  $idEmb!=0 && $idEmb2==0  ){
                for ($i=0; $i < 1; $i++) { 
                    $resultado[$i]=$idEmb+$i;
                }
                return $resultado;
            }
            //**2.-Varios productores en un rango de embarques
            elseif(count($idPro)>1 && $idEmb!=0 && $idEmb2!=0){
                for ($i=0; $i <= ($idEmb2-$idEmb); $i++) { 
                    $resultado[$i]=$idEmb+$i;
                }
                return $resultado;
            }
        
        }else if($op==2){
            $idPro=$_POST["idPro"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
           
            //Todos los productores una fecha
            if($idPro[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as e from fruta INNER JOIN productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where productor_fruta.fecha_compra = '$fecha1' GROUP BY fruta.id_embarque");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fecha
            elseif($idPro[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as e from fruta INNER JOIN productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where productor_fruta.fecha_compra between '$fecha1' and '$fecha2' GROUP BY fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idPro)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as e from fruta INNER JOIN productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where productor_fruta.fecha_compra = '$fecha1' and fruta.id_productores=$idPro[0] GROUP BY fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idPro)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT embarque.id as e from fruta INNER JOIN productores on fruta.id_productores=productores.id RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores=1 WHERE embarque.fecha_inicio BETWEEN '$fecha1' AND '$fecha2' OR embarque.fecha_fin BETWEEN '$fecha1' AND '$fecha2' order by embarque.id");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha
            elseif(count($idPro)>1 && $fecha1!="" && $fecha2==""){
                $array = $idPro;
                $Pel = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as e from fruta INNER JOIN productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta where productor_fruta.fecha_compra = '$fecha1' and fruta.id_productores in ($Pel) GROUP BY fruta.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores en un rango de  fechas
             elseif(count($idPro)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idPro;
                $Pel = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT embarque.id as e from fruta INNER JOIN productores on fruta.id_productores=productores.id RIGHT JOIN embarque on fruta.id_embarque=embarque.id and fruta.id_productores in ($Pel) WHERE embarque.fecha_inicio between '$fecha1' and '$fecha2' OR embarque.fecha_fin between '$fecha1' and '$fecha2' GROUP BY fruta.id_embarque ORDER BY embarque.id");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }
     
    }
    public function rendimientoE_c(){
        $sql=consultasModelo::rendimientoE();
        return $sql;
    }

    public function reportesData(){
        $id=$_POST['id'];

        $consulta= mainModel::ejecutar_consulta_simple("SELECT embarque.id, embarque.fecha_inicio, embarque.fecha_fin FROM embarque WHERE id=$id");

        return $consulta->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function listarPealadorBolsa(){
        $idPel=$_POST["idPel"];
        $idEmb=$_POST["idEmb"];
        $idEmb2=$_POST["idEmb2"];

        //Todos los peladores un embarque
        if($idPel[0]==9999 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m)
             as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque=$idEmb
            GROUP BY bolsas_pelador.id_pelador
            order by bolsas_pelador.id_pelador asc ");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPel[0]==9999 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
            GROUP BY  bolsas_pelador.id_pelador
            order by bolsas_pelador.id_pelador asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un pelador un embarque
        else if (count($idPel)==1 && $idEmb!=0 && $idEmb2==0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre,
             bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador=$idPel[0] and bolsas_pelador.id_embarque=$idEmb
            GROUP BY  bolsas_pelador.id_pelador order by bolsas_pelador.id_pelador asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un pelador rango de embarque
        else if (count($idPel)==1 && $idEmb!=0 && $idEmb2!=0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador=$idPel[0] and bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
            GROUP BY  bolsas_pelador.id_pelador order by bolsas_pelador.id_pelador asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios peladores un embarque
        elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2==0){
            $array = $idPel;
            $Pel = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador in ($Pel) and bolsas_pelador.id_embarque= $idEmb
            GROUP BY  bolsas_pelador.id_pelador order by bolsas_pelador.id_pelador asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios peladores rango de  embarques
         elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2!=0){
            $array = $idPel;
            $Pel = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, 
            bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas, pago_pe from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador in ($Pel) and bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
             GROUP BY  bolsas_pelador.id_pelador order by bolsas_pelador.id_pelador asc        
            ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
        
    }

    //Lista pagos pelador fecha

    public function 
    listarPeladorBolsaFecha(){
       
        $idPel=$_POST["idPel"];
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        //Todos los bolseros un embarque
        if($idPel[0]==9999 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m)
            as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
           INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
           where bolsas_pelador.fecha_trabajo_pe = '$fecha1'
           GROUP BY bolsas_pelador.id_pelador");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los bolseros rango de embarque
        elseif($idPel[0]==9999 && $fecha1!="" && $fecha2!=""){
            $query=mainModel::ejecutar_consulta_simple("       SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe BETWEEN '$fecha1' AND '$fecha2'
            GROUP BY   bolsas_pelador.id_pelador
            ORDER BY bolsas_pelador.id_pelador ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un bolsero un embarque
        else if (count($idPel)==1 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador=$idPel[0] and bolsas_pelador.fecha_trabajo_pe= '$fecha1'
            GROUP BY  bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un bolsero rango de embarque
        else if (count($idPel)==1 && $fecha1!="" && $fecha2!="" ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador=$idPel[0] and bolsas_pelador.fecha_trabajo_pe BETWEEN '$fecha1' and '$fecha2'
            GROUP BY  bolsas_pelador.id_pelador     ORDER BY bolsas_pelador.id_pelador ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios bolseros un embarque
        elseif(count($idPel)>1 && $fecha1!="" && $fecha2==""){
            $array = $idPel;
            $Pel = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador in ($Pel) and bolsas_pelador.fecha_trabajo_pe= '$fecha1'
            GROUP BY  bolsas_pelador.id_pelador     ORDER BY bolsas_pelador.id_pelador ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios bolseros rango de  embarques
         elseif(count($idPel)>1 && $fecha1!="" && $fecha2!=""){
            $array = $idPel;
            $Pel = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre,' ',peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha ,sum(bolsas_pelador.cantidad_bolsas_pe) as bolsas from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_pelador in ($Pel) and bolsas_pelador.fecha_trabajo_pe BETWEEN '$fecha1' and '$fecha2'
             GROUP BY bolsas_pelador.id_pelador         
             ORDER BY bolsas_pelador.id_pelador ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }
    //****************PAGO BOLSEROS */
    //--------------------listar pagos bolsero embarque
    public function listarBolseroPagosEmb(){
        $idBol=$_POST["idBol"];
        $idEmb=$_POST["idEmb"];
        $idEmb2=$_POST["idEmb2"];

        //Todos los peladores un embarque
        if($idBol[0]==9999 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre,
             bolsas_pelador.id_embarque, pelador_extra.fecha, pelador_extra.pago from bolsas_pelador
              INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id 
              INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
              WHERE pelador_extra.trabajo=2 and bolsas_pelador.id_embarque=$idEmb
                       UNION
             SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, bolsas_bolsero.id_embarque,
             bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero
            INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
            where bolsas_bolsero.id_embarque=$idEmb   
            GROUP BY id_bolsero,id_embarque
            ORDER BY id_bolsero ASC, fecha ASC  ");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idBol[0]==9999 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre,
             bolsas_pelador.id_embarque, pelador_extra.fecha, sum(pelador_extra.pago) as pago from bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
             INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador WHERE pelador_extra.trabajo=2 and bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2

            UNION
            
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha,
             sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero
                INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.id_embarque BETWEEN $idEmb and $idEmb2
                GROUP BY  id_bolsero
                ORDER BY   id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un pelador un embarque
        else if (count($idBol)==1 && $idEmb!=0 && $idEmb2==0 ){
            $query=mainModel::ejecutar_consulta_simple("  SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, 
            sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero 
                        INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                        where bolsas_bolsero.id_bolsero=$idBol[0] and bolsas_bolsero.id_embarque=$idEmb
                        GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un pelador rango de embarque
        else if (count($idBol)==1 && $idEmb!=0 && $idEmb2!=0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, 
            bolsas_pelador.id_embarque, pelador_extra.fecha, pelador_extra.pago from bolsas_pelador
             INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
              WHERE pelador_extra.trabajo=2 and bolsas_pelador.id_pelador=$idBol[0] and bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero 
                INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.id_bolsero=$idBol[0] and bolsas_bolsero.id_embarque BETWEEN $idEmb and $idEmb2
                GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

            
        }
        //Varios peladores un embarque
        elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2==0){
            $array = $idBol;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, 
            concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
             pelador_extra.fecha, pelador_extra.pago from bolsas_pelador 
             INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id 
             INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador 
             WHERE pelador_extra.trabajo=2 and bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador in ($Bol)
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero 
                        INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                        where bolsas_bolsero.id_bolsero in ($Bol) and bolsas_bolsero.id_embarque=$idEmb
                        GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios peladores rango de  embarques
         elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2!=0){
            $array = $idBol;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, pelador_extra.fecha, pelador_extra.pago from bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
            WHERE pelador_extra.trabajo=2 and bolsas_pelador.id_embarque BETWEEN 77 and 78 and bolsas_pelador.id_pelador in (1,3)
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
                        bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha,
                        sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago
                        FROM bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id 
                       where bolsas_bolsero.id_bolsero in ($Bol) and bolsas_bolsero.id_embarque BETWEEN $idEmb and $idEmb2
                       GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }
    //Lista bolsas bolsero fecha

    public function listarBolserosPagosFecha(){
        $idBol=$_POST["idBol"];
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        //Todos los bolseros una fecha
        if($idBol[0]==9999 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, 
            concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
             pelador_extra.fecha, sum( pelador_extra.pago) as pago from bolsas_pelador
             INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id 
             INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador 
             WHERE pelador_extra.trabajo=2 and fecha='$fecha1'
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
            bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago
            FROM bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
            where bolsas_bolsero.fecha_trabajo_bol='$fecha1'
            GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los bolseros rango de embarque
        elseif($idBol[0]==9999 && $fecha1!="" && $fecha2!=""){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero,
             concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
              pelador_extra.fecha, pelador_extra.pago from bolsas_pelador 
              INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
               INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador 
               WHERE pelador_extra.trabajo=2 and bolsas_pelador.fecha_trabajo_pe BETWEEN '$fecha1'  and '$fecha2'
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
             bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha,
              sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero
            INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id 
             where bolsas_bolsero.fecha_trabajo_bol BETWEEN '$fecha1'  and '$fecha2'
             GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un bolsero un embarque
        else if (count($idBol)==1 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero,
             concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, 
             pelador_extra.fecha, pelador_extra.pago from bolsas_pelador
              INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
               INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
               WHERE pelador_extra.trabajo=2 and bolsas_pelador.fecha_trabajo_pe= '2020-07-24' and bolsas_pelador.id_pelador=1
            UNION
            SELECT bolsas_bolsero.id_bolsero, 
             concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
             bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago FROM bolsas_bolsero
             INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
             where bolsas_bolsero.fecha_trabajo_bol= '$fecha1' AND bolsas_bolsero.id_bolsero=$idBol[0]
             GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un bolsero rango de embarque
        else if (count($idBol)==1 && $fecha1!="" && $fecha2!="" ){
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero,
             concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
              pelador_extra.fecha, pelador_extra.pago from bolsas_pelador 
              INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
               INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
                WHERE pelador_extra.trabajo=2 and bolsas_pelador.fecha_trabajo_pe BETWEEN '$fecha1' AND '$fecha2'
                 and bolsas_pelador.id_pelador=$idBol[0]
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
             bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago
             FROM bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
            where bolsas_bolsero.fecha_trabajo_bol BETWEEN '$fecha1' AND '$fecha2' and bolsas_bolsero.id_bolsero=$idBol[0]
            GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios bolseros una fecha 
        elseif(count($idBol)>1 && $fecha1!="" && $fecha2==""){
            $array = $idBol;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, 
            concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
             pelador_extra.fecha, pelador_extra.pago from bolsas_pelador
              INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id 
              INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador 
              WHERE pelador_extra.trabajo=2 and bolsas_pelador.fecha_trabajo_pe ='$fecha1'
               AND bolsas_pelador.id_pelador IN ($Bol)
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
            bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago
            FROM bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
            where bolsas_bolsero.fecha_trabajo_bol='$fecha1' and bolsas_bolsero.id_bolsero IN ($Bol)
            GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios bolseros rango de  fechas
         elseif(count($idBol)>1 && $fecha1!="" && $fecha2!=""){
            $array = $idBol;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT concat('P',bolsas_pelador.id_pelador) as id_bolsero, 
            concat(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque,
             pelador_extra.fecha, pelador_extra.pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador
            WHERE pelador_extra.trabajo=2 and bolsas_pelador.fecha_trabajo_pe BETWEEN '2020-07-24' AND '2020-07-24' and bolsas_pelador.id_pelador in (1,3)
            UNION
            SELECT bolsas_bolsero.id_bolsero, concat(bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre,
            bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol as fecha, sum(bolsas_bolsero.diaUno+bolsas_bolsero.diaDos+bolsas_bolsero.diaTres+bolsas_bolsero.diaCuatro+ bolsas_bolsero.diaCinco) as pago
            FROM bolsas_bolsero INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
            where bolsas_bolsero.fecha_trabajo_bol BETWEEN '$fecha1' AND '$fecha2' and bolsas_bolsero.id_bolsero IN ($Bol)
            GROUP BY id_bolsero 
                        ORDER BY id_bolsero  ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }

    //****************PAGO PELADORES */
    public function listarPagoPeladorEmb(){
        $idPel=$_POST["idPel"];
        $idEmb=$_POST["idEmb"];
        $idEmb2=$_POST["idEmb2"];

        //Todos los peladores un embarque
        if($idPel[0]==9999 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre,
             bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque=$idEmb
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPel[0]==9999 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un pelador un embarque
        else if (count($idPel)==1 && $idEmb!=0 && $idEmb2==0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador=$idPel[0]
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un pelador rango de embarque
        else if (count($idPel)==1 && $idEmb!=0 && $idEmb2!=0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2 and bolsas_pelador.id_pelador=$idPel[0]
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

            
        }
        //Varios peladores un embarque
        elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2==0){
            $array = $idPel;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador in ($Bol)
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios peladores rango de  embarques
         elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2!=0){
            $array = $idPel;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.id_embarque between  $idEmb and $idEmb2 and bolsas_pelador.id_pelador in ($Bol)
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }

    public function listarPagoPeladorFech(){
        $idPel=$_POST["idPel"];
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        //Todos los productores una fecha
        if($idPel[0]==9999 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, 
            bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe = '$fecha1'
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPel[0]==9999 && $fecha1!="" && $fecha2!=""){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre,
             bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2'
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un productor una fecha
        else if (count($idPel)==1 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe = '$fecha1' and bolsas_pelador.id_pelador=$idPel[0]
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un productor rango de fechas
        else if (count($idPel)==1 && $fecha1!="" && $fecha2!="" ){
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador=$idPel[0]
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios productores una fecha 
        elseif(count($idPel)>1 && $fecha1!="" && $fecha2==""){
            $array = $idPel;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe = '$fecha1' and bolsas_pelador.id_pelador in ($Bol)
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios productores rango de  fechas
         elseif(count($idPel)>1 && $fecha1!="" && $fecha2!=""){
            $array = $idPel;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT bolsas_pelador.id_pelador, concat(peladores.nombre, ' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, bolsas_pelador.id_embarque, bolsas_pelador.fecha_trabajo_pe as fecha, sum(bolsas_pelador.pago_pe) as pago from bolsas_pelador
            INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
            where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador in ($Bol)
            GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }

    //**************AGUINALDO FECHA */
    public function aguinaldoFecha(){
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        if($fecha1!='' && $fecha2!=''){
            $consulta= mainModel::ejecutar_consulta_simple("SELECT  embarque.fecha_inicio as fecha, gastos_embarque.id_embarque, gastos_embarque.cantidad as aguinaldo from embarque
            INNER JOIN gastos_embarque on gastos_embarque.id_embarque=embarque.id
            WHERE gastos_embarque.id_gasto=27 and embarque.fecha_inicio BETWEEN '$fecha1' and '$fecha2' order by embarque.id asc");
           return $consulta->fetchAll(PDO::FETCH_ASSOC);
        }elseif ($fecha1!='' && $fecha2==''){
            $consulta= mainModel::ejecutar_consulta_simple("SELECT  embarque.fecha_inicio as fecha, gastos_embarque.id_embarque, gastos_embarque.cantidad as aguinaldo from embarque
            INNER JOIN gastos_embarque on gastos_embarque.id_embarque=embarque.id
            WHERE gastos_embarque.id_gasto=27 and embarque.fecha_inicio='$fecha1' order by embarque.id asc");
           return $consulta->fetchAll(PDO::FETCH_ASSOC);
        }
    }
    //**************AGUINALDO EMBARQUE */
    public function aguinaldoEmb(){
        $idEmb=$_POST["idEmb"];
        $idEmb2=$_POST["idEmb2"];

        if($idEmb!=0 && $idEmb2!=0){
            
            $consulta= mainModel::ejecutar_consulta_simple("SELECT embarque.fecha_inicio as fecha, 
            gastos_embarque.id_embarque, gastos_embarque.cantidad as aguinaldo from embarque 
            INNER JOIN gastos_embarque on gastos_embarque.id_embarque=embarque.id
             WHERE gastos_embarque.id_gasto=27 and gastos_embarque.id_embarque between '$idEmb' and '$idEmb2' order by embarque.id asc");
            return $consulta->fetchAll(PDO::FETCH_ASSOC);
        
        }elseif ($idEmb!=0 && $idEmb2==0){
            
            $consulta= mainModel::ejecutar_consulta_simple("SELECT embarque.fecha_inicio as fecha, gastos_embarque.id_embarque, gastos_embarque.cantidad as aguinaldo from embarque
            INNER JOIN gastos_embarque on gastos_embarque.id_embarque=embarque.id
            WHERE gastos_embarque.id_gasto=27 and gastos_embarque.id_embarque =$idEmb order by embarque.id asc");
           return $consulta->fetchAll(PDO::FETCH_ASSOC);
        }
    }

    //------------Rendimiento de productores por fecha 
    public function rendfecha(){
        $idPro=$_POST["idPro"];
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        //Todos los productores una fecha
        if($idPro[0]==9999 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
             CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg ,
             productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
              INNER JOIN productores on fruta.id_productores=productores.id
               INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta 
               where productor_fruta.fecha_compra= '$fecha1'
                GROUP by fruta.id_productores
                 ORDER by  fruta.id_productores asc");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPro[0]==9999 && $fecha1!="" && $fecha2!=""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg ,
            productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
             INNER JOIN productores on fruta.id_productores=productores.id
              INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta 
              where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2'
              GROUP by fruta.id_productores
                ORDER by  fruta.id_productores asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un productor un embarque
        else if (count($idPro)==1 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg ,
            productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
             INNER JOIN productores on fruta.id_productores=productores.id
              INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta 
              where productor_fruta.fecha_compra = '$fecha1' and fruta.id_productores=$idPro[0]
               GROUP by fruta.id_productores, fruta.id_embarque
                ORDER by fruta.id_embarque, fruta.id_productores asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un productor rango de embarque
        else if (count($idPro)==1 && $fecha1!="" && $fecha2!="" ){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg , productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta INNER JOIN productores on fruta.id_productores=productores.id INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2' and fruta.id_productores=$idPro[0] GROUP by fruta.id_productores ORDER by  fruta.id_productores asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios productores una fecha 
        elseif(count($idPro)>1 && $fecha1!="" && $fecha2==""){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg ,
            productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
             INNER JOIN productores on fruta.id_productores=productores.id
              INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta 
              where productor_fruta.fecha_compra = '$fecha1' and fruta.id_productores in ($Bol)
               GROUP by  fruta.id_productores
                ORDER by  fruta.id_productores asc");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios productores rango de  fechas
         elseif(count($idPro)>1 && $fecha1!="" && $fecha2!=""){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_embarque as embarque, fruta.id_productores as id,
            CONCAT(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, ROUND(SUM(productor_fruta.peso),2) as kg ,
            productor_fruta.fecha_compra as fecha, round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
             INNER JOIN productores on fruta.id_productores=productores.id
              INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta 
              where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2' and fruta.id_productores in  ($Bol)
               GROUP by  fruta.id_productores
                ORDER by  fruta.id_productores asc ");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }

    //--------------Abonos de productores
    public function abonosFecha(){
        $idPro=$_POST["idPro"];
        $fecha1=$_POST["fech1"];
        $fecha2=$_POST["fech2"];

        //Todos los productores una fecha
        if($idPro[0]==9999 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra= ' $fecha1'
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores asc");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPro[0]==9999 && $fecha1!="" && $fecha2!=""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2'
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un productor una fecha
        else if (count($idPro)==1 && $fecha1!="" && $fecha2==""){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra= '$fecha1' and fruta.id_productores=$idPro[0]
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un productor rango de fechas
        else if (count($idPro)==1 && $fecha1!="" && $fecha2!="" ){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2' and fruta.id_productores=$idPro[0]
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC
           ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios productores una fecha 
        elseif(count($idPro)>1 && $fecha1!="" && $fecha2==""){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra= '$fecha1' and fruta.id_productores in ($Bol)
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios productores rango de  fechas
         elseif(count($idPro)>1 && $fecha1!="" && $fecha2!=""){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where productor_fruta.fecha_compra BETWEEN '$fecha1' and '$fecha2' and fruta.id_productores in ($Bol)
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }
    public function abonosEmbarque(){
        $idPro=$_POST["idPro"];
        $idEmb=$_POST["idEmb"];
        $idEmb2=$_POST["idEmb2"];

           //Todos los productores una fecha
           if($idPro[0]==9999 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, 
            concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre,
             prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida,
              prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque ='$idEmb' 
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores asc");
             return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Todos los productores rango de embarque
        elseif($idPro[0]==9999 && $idEmb!=0 && $idEmb2!=0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque BETWEEN '$idEmb' and '$idEmb2'
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }   
        //Un productor una fecha
        else if (count($idPro)==1 && $idEmb!=0 && $idEmb2==0){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque=$idEmb and fruta.id_productores=$idPro[0]
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Un productor rango de fechas
        else if (count($idPro)==1 && $idEmb!=0 && $idEmb2!=0 ){
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque BETWEEN '$idEmb' and '$idEmb2' and fruta.id_productores=$idPro[0]
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC
           ");
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }
        //Varios productores una embarque 
        elseif(count($idPro)>1 && $idEmb!=0 && $idEmb2==0){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque=$idEmb and fruta.id_productores in ($Bol)
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);
         }

         //Varios productores rango de  fechas
         elseif(count($idPro)>1 && $idEmb!=0 && $idEmb2!=0){
            $array = $idPro;
            $Bol = implode(",", $array);
            $query=mainModel::ejecutar_consulta_simple("SELECT fruta.id_productores as id, fruta.id_embarque as embarque, concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) as nombre, prestamos.fungicida,prestamos.fertilizante, prestamos.prestamo,prestamos.abono_fungicida, prestamos.abono_fertilizante, prestamos.abono_prestamo from prestamos
            INNER JOIN fruta on prestamos.id_fruta= fruta.id
            INNER JOIN productores on fruta.id_productores=productores.id
            INNER JOIN productor_fruta on fruta.id=productor_fruta.id_fruta
            where fruta.id_embarque BETWEEN '$idEmb' and '$idEmb2' and fruta.id_productores in ($Bol)
            GROUP BY fruta.id_embarque, fruta.id_productores
            ORDER by fruta.id_embarque, fruta.id_productores ASC");
            return $query->fetchAll(PDO::FETCH_ASSOC);

        }
    }

    // Gráfica, datos Y y X de bolsas peladores

    public function listaYBP(){
       
        $op= $_POST['op'];
         // op=1 -> por embarque
        // op=2 -> por fecha 
        if($op==1){
            $idPel=$_POST["idPel"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
    
            //Todos los peladores un embarque
            if($idPel[0]==9999 && $idEmb!=0 && $idEmb2==0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque=$idEmb
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador, bolsas_pelador.fecha_trabajo_pe");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de embarque
            elseif($idPel[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque between $idEmb and $idEmb2
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un pelador un embarque
            else if (count($idPel)==1 && $idEmb!=0 && $idEmb2==0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un pelador rango de embarque
            else if (count($idPel)==1 && $idEmb!=0 && $idEmb2!=0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque between $idEmb and $idEmb2 and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY   bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
                
            }
            //Varios peladores un embarque
            elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2==0){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios peladores rango de  embarques
             elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2!=0){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.id_embarque between $idEmb and $idEmb2 and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }else if($op==2){
            $idPel=$_POST["idPel"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idPel[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe ='$fecha1' 
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador ASC");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idPel[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2'
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idPel)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe ='$fecha1' and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador, bolsas_pelador.fecha_trabajo_pe ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idPel)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador ASC 
               ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idPel)>1 && $fecha1!="" && $fecha2==""){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe ='$fecha1' and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador ASC ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idPel)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(bolsas_pelador.cantidad_bolsas_pe) as e from bolsas_pelador
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }
    }

    public function listaXBP(){
        $op=$_POST['op'];
        //Por embarque
        if($op==1){
            $idPel=$_POST["idPel"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
                //Todos los peladores un embarque
                if($idPel[0]==9999 && $idEmb!=0 && $idEmb2==0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque=$idEmb 
                    GROUP BY  bolsas_pelador.id_pelador
                    ORDER BY  bolsas_pelador.id_pelador asc");
                     return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Todos los productores rango de embarque
                elseif($idPel[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque between  $idEmb and $idEmb2
                    GROUP BY  bolsas_pelador.id_pelador
                    ORDER BY  bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }   
                //Un pelador un embarque
                else if (count($idPel)==1 && $idEmb!=0 && $idEmb2==0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque=$idEmb and  bolsas_pelador.id_pelador=$idPel[0]
                    GROUP BY  bolsas_pelador.id_pelador
                    ORDER BY  bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Un pelador rango de embarque
                else if (count($idPel)==1 && $idEmb!=0 && $idEmb2!=0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque between  $idEmb and $idEmb2 and  bolsas_pelador.id_pelador=$idPel[0]
                    GROUP BY bolsas_pelador.id_embarque
                    ORDER BY  bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                    
                }
                //Varios peladores un embarque
                elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2==0){
                    $array = $idPel;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque=$idEmb and  bolsas_pelador.id_pelador in ($Bol)
                    GROUP BY  bolsas_pelador.id_pelador
                    ORDER BY  bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                 }
        
                 //Varios peladores rango de  embarques
                 elseif(count($idPel)>1 && $idEmb!=0 && $idEmb2!=0){
                    $array = $idPel;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    WHERE bolsas_pelador.id_embarque between  $idEmb and $idEmb2 and  bolsas_pelador.id_pelador  in ($Bol)
                    GROUP BY  bolsas_pelador.id_pelador
                    ORDER BY  bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }
        }
        //Por fecha
        else if ($op==2){
            $idPel=$_POST["idPel"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idPel[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe = '$fecha1'
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador ASC");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idPel[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2'
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idPel)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe = '$fecha1'  and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY  bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idPel)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador=$idPel[0]
                GROUP BY bolsas_pelador.id_embarque
                ORDER BY bolsas_pelador.id_pelador ASC");
            
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idPel)>1 && $fecha1!="" && $fecha2==""){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe = '$fecha1'  and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idPel)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idPel;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                WHERE bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador  in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador ASC");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }

    }

    // Gráfica, datos Y y X de Aguinaldos

    public function listaYAguinaldo(){
       
        $op= $_POST['op'];
         // op=1 -> por embarque
        // op=2 -> por fecha 
        if($op==1){
           
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
    
            //Un embarque
            if( $idEmb!=0 && $idEmb2==0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad) as e from gastos_embarque
                where  gastos_embarque.id_gasto=27 and gastos_embarque.id_embarque=$idEmb
                GROUP BY gastos_embarque.id_embarque
                ORDER BY gastos_embarque.id_embarque");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Rango de embarque
            elseif($idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad) as e from gastos_embarque
                where  gastos_embarque.id_gasto=27 and gastos_embarque.id_embarque between $idEmb and $idEmb2
                GROUP BY gastos_embarque.id_embarque
                ORDER BY gastos_embarque.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
          
        }else if($op==2){
            
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Una fecha
            if( $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad) as e from gastos_embarque
                INNER JOIN embarque on gastos_embarque.id_embarque=embarque.id
                where  gastos_embarque.id_gasto=27 and embarque.fecha_inicio= '$fecha1'
                GROUP BY gastos_embarque.id_embarque
                ORDER BY gastos_embarque.id_embarque");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Rango de fechas
            elseif( $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum(gastos_embarque.cantidad) as e from gastos_embarque
                INNER JOIN embarque on gastos_embarque.id_embarque=embarque.id
                where  gastos_embarque.id_gasto=27 and embarque.fecha_inicio  between '$fecha1' and '$fecha2'
                GROUP BY gastos_embarque.id_embarque
                ORDER BY gastos_embarque.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
        
        }
    }

    public function listaXAguinaldo(){
        $op= $_POST['op'];
        // op=1 -> por embarque
       // op=2 -> por fecha 
       if($op==1){
          
           $idEmb=$_POST["idEmb"];
           $idEmb2=$_POST["idEmb2"];
   
           //Un embarque
           if( $idEmb!=0 && $idEmb2==0){
               $query=mainModel::ejecutar_consulta_simple("SELECT gastos_embarque.id_embarque as e from gastos_embarque
               where gastos_embarque.id_gasto=27 and  gastos_embarque.id_embarque=$idEmb
               GROUP BY gastos_embarque.id_embarque
               ORDER BY gastos_embarque.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
           }
           //Rango de embarque
           elseif($idEmb!=0 && $idEmb2!=0){
               $query=mainModel::ejecutar_consulta_simple("SELECT gastos_embarque.id_embarque as e from gastos_embarque
               where gastos_embarque.id_gasto=27 and  gastos_embarque.id_embarque between $idEmb and $idEmb2
               GROUP BY gastos_embarque.id_embarque
               ORDER BY gastos_embarque.id_embarque");
               return $query->fetchAll(PDO::FETCH_ASSOC);
   
           }   
         
       }else if($op==2){
           
           $fecha1=$_POST["fech1"];
           $fecha2=$_POST["fech2"];
   
           //Una fecha
           if( $fecha1!="" && $fecha2==""){
               $query=mainModel::ejecutar_consulta_simple("SELECT gastos_embarque.id_embarque as e from gastos_embarque
               INNER JOIN embarque on gastos_embarque.id_embarque=embarque.id
               where gastos_embarque.id_gasto=27 and embarque.fecha_inicio='$fecha1'
               GROUP BY gastos_embarque.id_embarque
               ORDER BY gastos_embarque.id_embarque");
                return $query->fetchAll(PDO::FETCH_ASSOC);
           }
           //Rango de fechas
           elseif( $fecha1!="" && $fecha2!=""){
               $query=mainModel::ejecutar_consulta_simple("SELECT gastos_embarque.id_embarque as e from gastos_embarque
               INNER JOIN embarque on gastos_embarque.id_embarque=embarque.id
               where gastos_embarque.id_gasto=27 and embarque.fecha_inicio between '$fecha1' and '$fecha2'
               GROUP BY gastos_embarque.id_embarque
               ORDER BY gastos_embarque.id_embarque");
               return $query->fetchAll(PDO::FETCH_ASSOC);
   
           }   
       
       }

    }

    // Gráfica, datos Y y X de pago bolseros

    public function listaYPB(){
       
        $op= $_POST['op'];
         // op=1 -> por embarque
        // op=2 -> por fecha 
        if($op==1){
            $idBol=$_POST["idBol"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
    
            //Todos los peladores un embarque
            if($idBol[0]==9999 && $idEmb!=0 && $idEmb2==0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque=$idEmb
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de embarque
            elseif($idBol[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque between $idEmb and $idEmb2 
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un pelador un embarque
            else if (count($idBol)==1 && $idEmb!=0 && $idEmb2==0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque=$idEmb and  bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un pelador rango de embarque
            else if (count($idBol)==1 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque between $idEmb and $idEmb2 and  bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
                
            }
            //Varios peladores un embarque
            elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2==0){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque=$idEmb and  bolsas_bolsero.id_bolsero in($Bol)
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios peladores rango de  embarques
             elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2!=0){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.id_embarque between $idEmb and $idEmb2 and  bolsas_bolsero.id_bolsero in($Bol)
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }else if($op==2){
            $idBol=$_POST["idBol"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idBol[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1' 
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idBol[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1' and '$fecha2'
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idBol)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1' and bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idBol)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1' and '$fecha2' and bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idBol)>1 && $fecha1!="" && $fecha2==""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1' and bolsas_bolsero.id_bolsero in ($Bol)
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");;
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idBol)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_bolsero.pago_bol) as e from bolsas_bolsero
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1' and '$fecha2' and bolsas_bolsero.id_bolsero in ($Bol)
                GROUP BY  bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }
    }

    public function listaXPB(){
        $op=$_POST['op'];
        //Por embarque
        if($op==1){
            $idBol=$_POST["idBol"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
                //Todos los peladores un embarque
                if($idBol[0]==9999 && $idEmb!=0 && $idEmb2==0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque=$idEmb
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");
                     return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Todos los productores rango de embarque
                elseif($idBol[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque between $idEmb and $idEmb2
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }   
                //Un pelador un embarque
                else if (count($idBol)==1 && $idEmb!=0 && $idEmb2==0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque=$idEmb and bolsas_bolsero.id_bolsero=$idBol[0]
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Un pelador rango de embarque
                else if (count($idBol)==1 && $idEmb!=0 && $idEmb2!=0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque between $idEmb and $idEmb and bolsas_bolsero.id_bolsero=$idBol[0]
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");;
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                    
                }
                //Varios peladores un embarque
                elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2==0){
                    $array = $idBol;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque=$idEmb and bolsas_bolsero.id_bolsero in ($Bol)
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                 }
        
                 //Varios peladores rango de  embarques
                 elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2!=0){
                    $array = $idBol;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                    inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                    where bolsas_bolsero.id_embarque between $idEmb and $idEmb2 and bolsas_bolsero.id_bolsero in ($Bol)
                    GROUP BY bolsas_bolsero.id_bolsero
                    ORDER BY bolsas_bolsero.id_bolsero asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }
        }
        //Por fecha
        else if ($op==2){
            $idBol=$_POST["idBol"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idBol[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1'
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idBol[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1' and '$fecha2'
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idBol)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1' and bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idBol)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1'and '$fecha2' and bolsas_bolsero.id_bolsero=$idBol[0]
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idBol)>1 && $fecha1!="" && $fecha2==""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol='$fecha1' and bolsas_bolsero.id_bolsero in ($Bol)
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idBol)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(bolseros.nombre,' ', bolseros.Ap_p) as e from bolsas_bolsero
                inner JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id
                where bolsas_bolsero.fecha_trabajo_bol between '$fecha1' and '$fecha2' and bolsas_bolsero.id_bolsero in ($Bol)
                GROUP BY bolsas_bolsero.id_bolsero
                ORDER BY bolsas_bolsero.id_bolsero asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }

    }

     // Gráfica, datos Y y X de pago peladores

     public function listaYPP(){
       
        $op= $_POST['op'];
         // op=1 -> por embarque
        // op=2 -> por fecha 
        if($op==1){
            $idBol=$_POST["idPel"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
    
            //Todos los peladores un embarque
            if($idBol[0]==9999 && $idEmb!=0 && $idEmb2==0){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque=$idEmb
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de embarque
            elseif($idBol[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un pelador un embarque
            else if (count($idBol)==1 && $idEmb!=0 && $idEmb2==0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un pelador rango de embarque
            else if (count($idBol)==1 && $idEmb!=0 && $idEmb2!=0 ){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2 and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
                
            }
            //Varios peladores un embarque
            elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2==0){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT sum( bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios peladores rango de  embarques
             elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2!=0){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.id_embarque BETWEEN $idEmb and $idEmb2 and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }else if($op==2){
            $idBol=$_POST["idPel"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idBol[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe='$fecha1'
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idBol[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2'
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idBol)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe='$fecha1' and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idBol)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idBol)>1 && $fecha1!="" && $fecha2==""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe='$fecha1' and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idBol)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT SUM(bolsas_pelador.pago_pe) as e from bolsas_pelador
                where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador  in ($Bol)
                GROUP BY  bolsas_pelador.id_pelador
            ORDER BY   bolsas_pelador.id_pelador asc ");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }
    }

    public function listaXPP(){
        $op=$_POST['op'];
        //Por embarque
        if($op==1){
            $idBol=$_POST["idPel"];
            $idEmb=$_POST["idEmb"];
            $idEmb2=$_POST["idEmb2"];
                //Todos los peladores un embarque
                if($idBol[0]==9999 && $idEmb!=0 && $idEmb2==0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque=$idEmb
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                     return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Todos los productores rango de embarque
                elseif($idBol[0]==9999 && $idEmb!=0 && $idEmb2!=0){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque between $idEmb and $idEmb
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }   
                //Un pelador un embarque
                else if (count($idBol)==1 && $idEmb!=0 && $idEmb2==0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador=$idBol[0]
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                }
                //Un pelador rango de embarque
                else if (count($idBol)==1 && $idEmb!=0 && $idEmb2!=0 ){
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque between $idEmb and $idEmb2 and bolsas_pelador.id_pelador=$idBol[0]
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                    
                }
                //Varios peladores un embarque
                elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2==0){
                    $array = $idBol;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.id_pelador in ($Bol)
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
                 }
        
                 //Varios peladores rango de  embarques
                 elseif(count($idBol)>1 && $idEmb!=0 && $idEmb2!=0){
                    $array = $idBol;
                    $Bol = implode(",", $array);
                    $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                    INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                    where bolsas_pelador.id_embarque between $idEmb and $idEmb2 and bolsas_pelador.id_pelador in ($Bol)
                    GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                    return $query->fetchAll(PDO::FETCH_ASSOC);
        
                }
        }
        //Por fecha
        else if ($op==2){
            $idBol=$_POST["idPel"];
            $fecha1=$_POST["fech1"];
            $fecha2=$_POST["fech2"];
    
            //Todos los productores una fecha
            if($idBol[0]==9999 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe= '$fecha1' 
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                 return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Todos los productores rango de fechas
            elseif($idBol[0]==9999 && $fecha1!="" && $fecha2!=""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe between '$fecha1' and '$fecha2'
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }   
            //Un productor una fecha
            else if (count($idBol)==1 && $fecha1!="" && $fecha2==""){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe= '$fecha1' and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Un productor rango de fechas
            else if (count($idBol)==1 && $fecha1!="" && $fecha2!="" ){
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe= '$fecha1' and bolsas_pelador.id_pelador=$idBol[0]
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
            }
            //Varios productores una fecha 
            elseif(count($idBol)>1 && $fecha1!="" && $fecha2==""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe= '$fecha1' and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
             }
    
             //Varios productores rango de  fechas
             elseif(count($idBol)>1 && $fecha1!="" && $fecha2!=""){
                $array = $idBol;
                $Bol = implode(",", $array);
                $query=mainModel::ejecutar_consulta_simple("SELECT concat(peladores.nombre,' ', peladores.Ap_p) as e from bolsas_pelador
                INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id
                where bolsas_pelador.fecha_trabajo_pe between  '$fecha1' and '$fecha2' and bolsas_pelador.id_pelador in ($Bol)
                GROUP BY bolsas_pelador.id_pelador
                ORDER BY bolsas_pelador.id_pelador asc");
                return $query->fetchAll(PDO::FETCH_ASSOC);
    
            }
        }
    }



}