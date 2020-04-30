<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class productorModelo extends mainModel{

		protected function registroProductorModelo($datos){
			$query=mainModel::conectar()->prepare("call addProductores(:Nombre, :ApP, :ApM)");
			$query->bindParam(":Nombre", $datos['Nombre']);
			$query->bindParam(":ApP", $datos['ApP']);
			$query->bindParam(":ApM", $datos['ApM']);
			$query->execute();
			return $query;
			/* INSERT INTO `productores` (`id`, `nombre`, `Ap_p`, `Ap_m`) VALUES
(1, 'ALE', 'LOPEZ', 'CERVERA'),
(8, 'ALBERT', 'RAMOS', 'GONZALEZ'),
(9, 'ADAN', 'ESCOBAR', 'R'),
(12, 'EJEMPLO 1', 'EXAMPLE 1', 'RAMZ'),
(15, 'EJEMPLO', 'EXAMPLE', 'RAMZ'),
(16, 'JUAN', 'LUNA', 'DOMINGUEZ'),
(17, 'LEONARDO', 'GUTIERREZ', 'MENDOSA'),
(18, 'CAMILA', 'RAMIREZ', 'CAMPOS'),
(19, 'MIRANDA', 'JIMENEZ', 'CRUZ'),
(20, 'DANIEL', 'LUNA', 'PEREZ'),
(21, 'luis', 'ramos', 'cervera'); */
			
		}

		protected function actualizarProductorModelo($datos){
			$query=mainModel::conectar()->prepare("call actualizarPro(:Id, :Nombre, :ApP, :ApM)");
			$query->bindParam(":Id", $datos['Id']);
			$query->bindParam(":Nombre", $datos['Nombre']);
			$query->bindParam(":ApP", $datos['ApP']);
			$query->bindParam(":ApM", $datos['ApM']);
        	$query->execute();
        	return $query->fetchAll(PDO::FETCH_ASSOC);
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