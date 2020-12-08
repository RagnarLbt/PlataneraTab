<?php
	if ($peticionAjax) {
		require_once "../modelos/updateModelo.php";
	} else {
		require_once "./modelos/updateModelo.php";
    }

    class updateControlador extends updateModelo{
        
        public function listaEmb_controlador(){
            $sql=updateModelo::listaEmb_modelo();
			return $sql;
        }

        public function listaEmbActivos_controlador(){
            $sql=updateModelo::listaEmbActivos_modelo();
            return $sql;
        }

        public function listaProd_controlador(){
            $idE =mainModel::limpiar_cadena($_POST['id']);

            $sql=updateModelo::listaProd_modelo($idE);
			return $sql;
        }

        public function totalesProd_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::totalesProd_modelo($idE);
			return $sql;
        }
        
        public function updateProd_controlador(){
            $embarque=$_POST['embarque'];
            $frutaId=$_POST['idFruta'];
            $prestamoId=$_POST['idPF'];
            $kilos=$_POST['kilos'];
            
            $pagoFruta=$_POST['pagoFruta'];
            $newPagoFruta=$_POST['pagoFruNew'];
            
            $fungicida=$_POST['fungicida'];
            $newFungicida=$_POST['fungicidaNew'];

            $fertilizante=$_POST['fertilizante'];
            $newFertilizante=$_POST['fertilizanteNew'];
            
            $prestamo=$_POST['prestamo'];
            $newPrestamo=$_POST['prestamoNew'];
            
            $abono_fertilizante=$_POST['abonoFer'];
            $new_abono_Fertilizante=$_POST['aFerNew'];
            
            $abono_fungicida=$_POST['abonoFun'];
            $new_abono_Fungicida=$_POST['aFunNew'];
            
            $abono_prestamo=$_POST['abono_prestamo'];
            $new_abono_Prestamo=$_POST['aPresNew'];

            $noPFun=$_POST['noPFun'];
            $noPFer=$_POST['noPFer'];
            $noPPre=$_POST['noPPre'];
            $noPFunNew=$_POST['noPFunNew'];
            $noPFerNew=$_POST['noPFerNew'];
            $noPPreNew=$_POST['noPPreNew'];
	           
            $sql=mainModel::ejecutar_consulta_simple("CALL updateProd($embarque, $frutaId, $prestamoId, $kilos, $pagoFruta, $newPagoFruta, $fungicida, $newFungicida, $fertilizante, $newFertilizante, $prestamo, $newPrestamo, $abono_fungicida, $new_abono_Fungicida, $abono_fertilizante, $new_abono_Fertilizante, $abono_prestamo, $new_abono_Prestamo, $noPFun, $noPFer, $noPPre, $noPFunNew, $noPFerNew, $noPPreNew)");

            if($sql->rowCount()>=1){
                return "OK";
            }else{
                return $sql;
            }

			//$sql=updateModelo::updateProd($idE, $precioProd, $cantidadProd,  $insumoProd,  $prestamoProd,  $abono_insumo,  $abono_prestamo ,  $idProd);
        }

        public function listaToston_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::listaToston_modelo($idE);
			return $sql;
        }

        public function totalToston_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::totalToston_modelo($idE);
			return $sql;
        }

        public function updateToston_controlador(){
            $idE =$_POST['id'];
            $idToston =$_POST['idP'];
            $a = $_POST['a'];
            $b = $_POST['b'];
            $c = $_POST['c'];
            $d = $_POST['d'];
            $e = $_POST['e'];

            $sql=updateModelo::updateToston_modelo($idE, $idToston, $a, $b, $c, $d, $e);

            if($sql->rowCount()>=1){
                return "OK";
            }else{
                return $sql;
            }
        }

        public function listaToston(){
            $datos=mainModel::ejecutar_consulta_simple("SELECT  planilla_toston.id, concat(planilla_toston.nombre, ' ', planilla_toston.ap_p,' ', planilla_toston.ap_m) as nombre from planilla_toston");
            return $datos->fetchAll(PDO::FETCH_ASSOC);
        }

        public function  deleteToston_controlador(){
            $idEmb=$_POST['embarque'];
            $idToston=$_POST['idToston'];
            
            $sql=mainModel::ejecutar_consulta_simple("CALL update_planilla(2, $idEmb, 0, 0, 0, 0, 0, 0, $idToston, 0) ");

            if($sql->rowCount()>=1){
                return "OK1null";
            }else{
                return $sql;
            }
        }

        public function  agregarToston(){
            $idEmb=$_POST['embarque'];
            $idToston=$_POST['id'];
            $fecha= date("Y-m-d"); 
            $sql=mainModel::ejecutar_consulta_simple("CALL update_planilla(3, $idEmb,0,0,0,0,0,0,$idToston,'$fecha') ");

            if($sql->rowCount()>=1){
                return "OK1null";
            }else{
                return $sql;
            }
        }

        public function listaBolseros_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::listaBolseros_modelo($idE);
			return $sql;
        }

        public function listaBolserosExtra_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::listaBolserosExtra_modelo($idE);
			return $sql;
        }

        public function totalBolseros_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::totalBolseros_modelo($idE);
			return $sql;
        }

        public function updateBolseros_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['embarque']);
            $idBolsero =  mainModel::limpiar_cadena($_POST['idBolsero']);
            $a = $_POST['a'];
            $b = $_POST['b'];
            $c = $_POST['c'];
            $d = $_POST['d'];
            $e = $_POST['e'];

            $sql=updateModelo::updateBolseros_modelo($idE, $idBolsero, $a, $b, $c, $d, $e);
            
            if($sql->rowCount()>=1){
                return "OK";
            }else{
                return $sql;
            }
        }

        public function deleteBolsero(){
            $idEmb=$_POST['embarque'];
            $idBolsero=$_POST['idBolsero'];
            $sql=mainModel::ejecutar_consulta_simple("CALL update_bolseros(2, $idEmb,0,0,0,0,0,$idBolsero) ");
            
            if($sql->rowCount()>=1){
                return "OK1null";
            }else{
                return $sql;
            }
        }
        
        public function insertBolsero(){
            $idEmb=$_POST['embarque'];
            $idBolsero=$_POST['id'];
            $sql=mainModel::ejecutar_consulta_simple("CALL update_bolseros(3, $idEmb,0,0,0,0,0,$idBolsero) ");
            
            if($sql->rowCount()>=1){
                return "OK1null";
            }else{
                return $sql;
            }
        }

        public function totalBolserosExtra_controlador(){
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $sql=updateModelo::totalBolserosExtra_modelo($idE);
			return $sql;
        }

        public function updateBolserosExtra_controlador(){
            
            $idE =  mainModel::limpiar_cadena($_POST['id']);
            $idBolseroExtra =  mainModel::limpiar_cadena($_POST['idBolseroExtra']);
          
            $pagoBolseroExtra=  mainModel::limpiar_cadena($_POST['pagoBolseroExtra']);

            $sql=updateModelo::updateBolserosExtra_modelo($idE, $idBolseroExtra, $pagoBolseroExtra);
			return $sql;
        }

    };