<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class trabajadoresModelo extends mainModel{

		protected function registroTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("INSERT INTO `peladores`(`nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `foto`) VALUES (:Nombre, :ApP, :ApM, :Edad, :Tel, :Dir, :Cuenta, :Tipo, :Foto)");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("INSERT INTO `bolseros`(`nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `foto`) VALUES (:Nombre, :ApP, :ApM, :Edad, :Tel, :Dir, :Cuenta, :Tipo, :Foto)");
            }elseif($datos['opc']==3){
                $query=mainModel::conectar()->prepare("INSERT INTO `planilla_toston`(`nombre`, `ap_p`, `ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `tipo`, `foto`) VALUES (:Nombre, :ApP, :ApM, :Edad, :Tel, :Dir, :Cuenta, :Tipo, :Foto)");
            }
			$query->bindParam(":Nombre", $datos['Nombre']);
			$query->bindParam(":ApP", $datos['ApP']);
			$query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Edad", $datos['Edad']);
            $query->bindParam(":Dir", $datos['Dir']);
            $query->bindParam(":Tel", $datos['Tel']);
            $query->bindParam(":Cuenta", $datos['Cuenta']);
            $query->bindParam(":Foto", $datos['Foto']);
            $query->bindParam(":Tipo", $datos['opc']);
			$query->execute();
			return $query;
        }

        protected function actualizarTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("UPDATE `peladores` SET `nombre`=:Nombre,`Ap_p`=:ApP,`Ap_m`=:ApM,`edad`=:Edad,`telefono`=:Tel,`direccion`=:Dir,`no_cuenta`=:Cuenta,`Tipo`=:Tipo, `foto`=:Foto WHERE id = :Id");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("UPDATE `bolseros` SET `nombre`=:Nombre,`Ap_p`=:ApP,`Ap_m`=:ApM,`edad`=:Edad,`telefono`=:Tel,`direccion`=:Dir,`no_cuenta`=:Cuenta,`Tipo`=:Tipo, `foto`=:Foto WHERE id = :Id");
            }elseif ($datos['opc']==3) {
                $query=mainModel::conectar()->prepare("UPDATE `planilla_toston` SET `nombre`=:Nombre,`ap_p`=:ApP,`ap_m`=:ApM,`edad`=:Edad,`telefono`=:Tel,`direccion`=:Dir,`no_cuenta`=:Cuenta,`Tipo`=:Tipo, `foto`=:Foto WHERE id = :Id");
            }
            $query->bindParam(":Id", $datos['Id']);
            $query->bindParam(":Nombre", $datos['Nombre']);
            $query->bindParam(":ApP", $datos['ApP']);
            $query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Edad", $datos['Edad']);
            $query->bindParam(":Dir", $datos['Dir']);
            $query->bindParam(":Tel", $datos['Tel']);
            $query->bindParam(":Cuenta", $datos['Cuenta']);
            $query->bindParam(":Tipo", $datos['opc']);
            $query->bindParam(":Foto", $datos['Foto']);
            $query->execute();
            return $query;
        }

        protected function eliminarTrabajadorModelo($datos){
            if($datos['opc']==1){
                $query=mainModel::conectar()->prepare("UPDATE `peladores` SET estado=:Estado WHERE id=:Id");
            }elseif($datos['opc']==2){
                $query=mainModel::conectar()->prepare("UPDATE `bolseros` SET estado=:Estado WHERE id=:Id");
            }elseif ($datos['opc']==3) {
                $query=mainModel::conectar()->prepare("UPDATE `planilla_toston` SET estado=:Estado WHERE id=:Id");
            }
            $query->bindParam(":Id", $datos['Id']);
            $query->bindParam(":Estado", $datos['estado']);
            $query->execute();
            return $query;
        }

        protected function listaBolserosModelo(){
        	$query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, foto, estado FROM `bolseros`");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaTostonModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `ap_p` Ap_p, `ap_m` Ap_m, `edad`, `telefono`, `direccion`, `no_cuenta`, `tipo`, foto, estado FROM `planilla_toston`");
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaPeladoresModelo(){
        	$query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, foto, estado FROM `peladores`");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaGeneralModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, concat(`nombre`, ' ', `Ap_p`, ' ', `Ap_m`) as name, `Tipo`, foto FROM `bolseros`");
            $query->execute();
            $sql=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`,  concat(`nombre`, ' ', `Ap_p`, ' ', `Ap_m`) as name, `Tipo`, foto FROM `peladores`");
            $sql->execute();
            return array_merge($query->fetchAll(PDO::FETCH_ASSOC), $sql->fetchAll(PDO::FETCH_ASSOC));
        }

        /*----------  Listas para el embarque, donde se muestran solo los trabajadores activos  ----------*/
        protected function listaEmbarqueBolserosModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, foto, estado FROM `bolseros` where estado=1");
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaEmbarqueTostonModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `ap_p` Ap_p, `ap_m` Ap_m, `edad`, `telefono`, `direccion`, `no_cuenta`, `tipo`, foto FROM `planilla_toston` where estado=1");
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaEmbarquePeladoresModelo(){
            $query=mainModel::conectar()->prepare("SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, foto FROM `peladores` where estado=1");
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        }        

    }