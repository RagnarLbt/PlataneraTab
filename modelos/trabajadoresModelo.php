<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class trabajadoresModelo extends mainModel{

		protected function registroTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("call addPelador(:Nombre, :ApP, :ApM, :Tipo)");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("call addBolsero(:Nombre, :ApP, :ApM, :Tipo)");
            }
			$query->bindParam(":Nombre", $datos['Nombre']);
			$query->bindParam(":ApP", $datos['ApP']);
			$query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Tipo", $datos['opc']);
			$query->execute();
			return $query;
        }

        protected function actualizarTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("UPDATE `peladores` SET `nombre`=:Nombre, `Ap_p`=:ApP, `Ap_m`=:ApM, `Tipo` = :Tipo WHERE id = :Id");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("UPDATE `bolseros` SET `nombre`=:Nombre, `Ap_p`=:ApP, `Ap_m`=:ApM, `Tipo` = :Tipo WHERE id = :Id");
            }
            $query->bindParam(":Id", $datos['Id']);
            $query->bindParam(":Nombre", $datos['Nombre']);
            $query->bindParam(":ApP", $datos['ApP']);
            $query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Tipo", $datos['opc']);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function eliminarTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("DELETE FROM `peladores` WHERE id = :Id");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("DELETE FROM `bolseros` WHERE id = :Id");
            }
            $query->bindParam(":Id", $datos['Id']);
            $query->execute();
            return $query;
        }

        protected function listaBolserosModelo(){
        	$query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaPeladoresModelo(){
        	$query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaGeneralModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, concat(`nombre`, ' ', `Ap_p`, ' ', `Ap_m`) as name, `Tipo` FROM `bolseros`");
            $query->execute();
            $sql=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`,  concat(`nombre`, ' ', `Ap_p`, ' ', `Ap_m`) as name, `Tipo` FROM `peladores`");
            $sql->execute();
            return array_merge($query->fetchAll(PDO::FETCH_ASSOC), $sql->fetchAll(PDO::FETCH_ASSOC));
        }

    }