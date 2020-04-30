<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class embarqueModelo extends mainModel{
		
		protected function crearEmbarqueModelo($datos){
			//$query=mainModel::conectar()->prepare("calladdEmbarque(:Id, :FechaIni)");
			$query=mainModel::conectar()->prepare("INSERT INTO `embarque`(`id`, `fecha_inicio`, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, `contenedor`, `no_sello`, `no_bolsas`, `matricula`, `temperatura`, `nombre_conductor`) VALUES (:Id, :FechaIni, 1, '', 0, '', '', 0, '', 0, '')");
			$query->bindParam(":Id", $datos['Id']);
			$query->bindParam(":FechaIni", $datos['FechaIni']);
			$query->execute();
			return $query;
		}

		protected function obtenerEmbarqueModelo(){
			$query=mainModel::conectar()->prepare("call verEmbarque()");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function seleccionEmbarqueModelo($id){
			$query=mainModel::conectar()->prepare("call verEmb(:Id)");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function asistenciaEmbarqueModelo($datos){
			if($datos['tipo']==1){
				$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_pelador`(`id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`) VALUES (:Id, :Embarque, :Fecha, 0, 0)");
			}elseif($datos['tipo']==2){
				$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_bolsero`(`id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `cantidad_bolsas_bol`, `pago_bol`) VALUES (:Id, :Embarque, :Fecha, 0, 0)");
			}
			$query->bindParam("Id", $datos['id_trab']);
			$query->bindParam("Embarque", $datos['embarque']);
			$query->bindParam("Fecha", $datos['fecha']);
			$query->execute();
			return $query;
		}

		protected function frutaEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("INSERT INTO `fruta`(`id_productores`, `id_fruta`, `peso_kg`, `pago`, `fecha_compra`, `cant_bolsas`, `id_embarque`, `dia_letra`, `foto_fruta`) VALUES (:Id, :IdF, :Peso, :Pago, :Fecha, 0, :Embarque, '', '')");
			$query->bindParam(":Id", $datos['idProd']);
			$query->bindParam(":IdF", $datos['idFruta']);
			$query->bindParam(":Peso", $datos['peso']);
			$query->bindParam(":Pago", $datos['total']);
			$query->bindParam(":Embarque", $datos['embarque']);
			$query->bindParam(":Fecha", $datos['fecha']);
			$query->execute();
			return $query;
		}

		protected function listafrutaEmbarqueModelo($id){
			$query = mainModel::conectar()->prepare("SELECT f.`id` as id_f, id_fruta, concat(p.nombre,' ', p.Ap_p, ' ', p.Ap_m) as nombre, f.`peso_kg` FROM `fruta` as f, productores as p WHERE f.id_embarque=:Id AND f.`id_productores` = p.id");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function peladoresDiaEmbarqueModelo($datos){
			$query= mainModel::conectar()->prepare("SELECT bolsas_pelador.`id` as id_p, id_pelador, concat( peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, `cantidad_bolsas_pe` FROM `bolsas_pelador`, peladores WHERE id_embarque= :Id AND fecha_trabajo_pe= :Fecha AND peladores.id = id_pelador");

			$query->bindParam(":Id", $datos['Id']);
			$query->bindParam(":Fecha", $datos['Fecha']);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function bolserosDiaEmbarqueModelo($datos){
			$query= mainModel::conectar()->prepare("SELECT bolsas_bolsero.`id` as id_b, id_bolsero, concat( bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, `cantidad_bolsas_bol` FROM `bolsas_bolsero`, bolseros WHERE id_embarque= :Id AND bolseros.id = id_bolsero AND fecha_trabajo_bol= :Fecha ");

			$query->bindParam(":Id", $datos['Id']);
			$query->bindParam(":Fecha", $datos['Fecha']);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function finalizarDiaEmbarqueModelo($id){
			$query=mainModel::conectar()->prepare("UPDATE `embarque` SET `dia_actual`= (`dia_actual`+1) WHERE id=:Id");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function addBolsaPeladorEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `bolsas_pelador` SET `cantidad_bolsas_pe`= (`cantidad_bolsas_pe` + 1),`pago_pe`= (`pago_pe` + :Pago) WHERE `id`=:Id AND `id_embarque`=:Embarque AND `fecha_trabajo_pe`=:Fecha");
			$query->bindParam("Pago", $datos['Pago']);
			$query->bindParam("Embarque", $datos['Embarque']);
			$query->bindParam("Id", $datos['Id_pelador']);
			$query->bindParam("Fecha", $datos['Fecha']);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function addBolsaBolseroEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `bolsas_bolsero` SET `cantidad_bolsas_bol`= (`cantidad_bolsas_bol` + 1),`pago_bol`= (`pago_bol` + :Pago) WHERE `id_bolsero`=:Id AND `id_embarque`=:Embarque AND `fecha_trabajo_bol`=:Fecha");
			$query->bindParam("Embarque", $datos['Embarque']);
			$query->bindParam("Id", $datos['Id_bolsero']);
			$query->bindParam("Fecha", $datos['Fecha']);
			$query->bindParam("Pago", $datos['Pago']);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function addBolsaEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `embarque` SET `cant_bolsas_embarque`= (`cant_bolsas_embarque` + 1) WHERE id=:Embarque");
			$query->bindParam("Embarque", $datos['Embarque']);
			$query->execute();
			return $query;
		}

		protected function finalizarEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `embarque` SET `fecha_fin`=:Fecha, `contenedor`=:Contenedor,`no_sello`=:Sello,`matricula`=:Matricula,`temperatura`=:Temperatura,`nombre_conductor`=:Conductor WHERE `id`=:Embarque");
			$query->bindParam("Embarque", $datos['Embarque']);
			$query->bindParam("Fecha", $datos['Fecha']);
			$query->bindParam("Contenedor", $datos['Contenedor']);
			$query->bindParam("Sello", $datos['Sello']);
			$query->bindParam("Matricula", $datos['Matricula']);
			$query->bindParam("Temperatura", $datos['Temperatura']);
			$query->bindParam("Conductor", $datos['Conductor']);
			$query->execute();
			return $query;
		}

	}