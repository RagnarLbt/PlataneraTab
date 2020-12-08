<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class gastosModelo extends mainModel{

		protected function obtenerEmbarqueModelo(){
			$query=mainModel::conectar()->prepare("call verEmbarque()");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function seleccionEmbarqueModelo($id){
			$query=mainModel::conectar()->prepare("SELECT total_gastos FROM `embarque` WHERE id =:Id");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function listaGastosModelo(){
			$query=mainModel::conectar()->prepare("SELECT id_gasto, nombre FROM `gastos` WHERE !(id_gasto>=1 && id_gasto<=4) && !(id_gasto>=23 && id_gasto<=24) && !(id_gasto=29)");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function listaTodosLosGastosModelo(){
			$query=mainModel::conectar()->prepare("SELECT id_gasto, nombre FROM `gastos` ORDER BY id_gasto ASC");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function registroGastosModelo($datos){
			$idT=mainModel::generaId('gastos_embarque', $datos['Id_Embarque']);
			$query=mainModel::conectar()->prepare("INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`, `extra`) VALUES (:Id, :Id_Embarque, :Id_Gasto, :Cantidad, :Concepto)");
			$query->bindParam(":Id", $idT);
			$query->bindParam(":Id_Embarque", $datos['Id_Embarque']);
			$query->bindParam(":Id_Gasto", $datos['Id_Gasto']);
			$query->bindParam(":Cantidad", $datos['Cantidad']);
			$query->bindParam(":Concepto", $datos['Concepto']);
			$query->execute();
			return $query;
		}

		protected function agregarGasto($datos){
			$sql=mainModel::conectar()->prepare("UPDATE `embarque` SET `total_gastos`=(`total_gastos` + :Cantidad) WHERE `id`=:Id");
			$sql->bindParam(":Id", $datos['Id_Embarque']);
			$sql->bindParam(":Cantidad", $datos['Cantidad']);
			$sql->execute();
			return $sql;
		}

		protected function listaGastosRegistrados($id){
			$query=mainModel::conectar()->prepare("SELECT gastos.id_gasto, nombre, SUM(gastos_embarque.cantidad) as total, gastos_embarque.extra FROM gastos INNER JOIN gastos_embarque ON gastos_embarque.id_gasto=gastos.id_gasto AND gastos_embarque.id_embarque=$id GROUP BY gastos.id_gasto");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function listaGastosConsultas($id){
			$query=mainModel::conectar()->prepare("SELECT gastos_embarque.id, gastos.id_gasto idg, gastos.nombre, gastos_embarque.extra, gastos_embarque.cantidad from gastos_embarque inner JOIN gastos on gastos_embarque.id_gasto= gastos.id_gasto INNER join embarque on gastos_embarque.id_embarque=embarque.id where embarque.id=$id AND gastos_embarque.cantidad>0 order by gastos_embarque.extra ASC");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);	
		}

		protected function updatePrecioModelo($id, $cantidad, $pelador, $bolsero){
			$query=mainModel::conectar()->prepare("UPDATE `precio_compra` SET `cantidad`=:Cantidad,`pago_bolsero`=:Bolsero,`pago_pelador`=:Pelador WHERE `id_precio`=:Id");
			$query->bindParam(":Id", $id);
			$query->bindParam(":Cantidad", $cantidad);
			$query->bindParam(":Pelador", $pelador);
			$query->bindParam(":Bolsero", $bolsero);
			$query->execute();
			return $query;
		}

		protected function modificarTipoGastoModelo($id, $nombre){
			$query=mainModel::conectar()->prepare("UPDATE `gastos` SET `nombre`=:Nombre WHERE `id_gasto`=:Id");
			$query->bindParam(":Id", $id);
			$query->bindParam(":Nombre", $nombre);
			$query->execute();
			return $query;
		}

	}