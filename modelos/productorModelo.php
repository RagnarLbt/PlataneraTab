<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class productorModelo extends mainModel{

		protected function registroProductorModelo($datos){
			$query=mainModel::conectar()->prepare("INSERT INTO `productores`(`nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `foto`) VALUES (:Nombre, :ApP, :ApM, :Edad, :Tel, :Dir, :Cuenta, :Foto)");
			$query->bindParam(":Nombre", $datos['Nombre']);
			$query->bindParam(":ApP", $datos['ApP']);
			$query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Edad", $datos['Edad']);
            $query->bindParam(":Dir", $datos['Dir']);
            $query->bindParam(":Tel", $datos['Tel']);
            $query->bindParam(":Cuenta", $datos['Cuenta']);
            $query->bindParam(":Foto", $datos['Foto']);
			$query->execute();
			return $query;
		}

		protected function actualizarProductorModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `productores` SET `nombre`=:Nombre,`Ap_p`=:ApP,`Ap_m`=:ApM,`edad`=:Edad,`telefono`=:Tel,`direccion`=:Dir,`no_cuenta`=:Cuenta, `foto`=:Foto WHERE id = :Id");
			$query->bindParam(":Id", $datos['Id']);
            $query->bindParam(":Nombre", $datos['Nombre']);
            $query->bindParam(":ApP", $datos['ApP']);
            $query->bindParam(":ApM", $datos['ApM']);
            $query->bindParam(":Edad", $datos['Edad']);
            $query->bindParam(":Dir", $datos['Dir']);
            $query->bindParam(":Tel", $datos['Tel']);
            $query->bindParam(":Cuenta", $datos['Cuenta']);
            $query->bindParam(":Foto", $datos['Foto']);
        	$query->execute();
        	return $query;
		}

		protected function eliminarProductorModelo($id){
			$query=mainModel::conectar()->prepare("call deleteProd(:Id)");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query;
		}

		protected function listaProductorModelo(){
        	$query=mainModel::conectar()->prepare("call verListaProd()");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function listaOrdenadaProductorModelo(){
        	$query=mainModel::conectar()->prepare("call verListaOProd()");
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);	
        }


	}