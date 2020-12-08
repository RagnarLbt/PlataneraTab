<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class embarqueModelo extends mainModel{
		
		protected function crearEmbarqueModelo($datos){
			//$query=mainModel::conectar()->prepare("calladdEmbarque(:Id, :FechaIni)");
			$query=mainModel::conectar()->prepare("CALL addEmbarque(:Id, :FechaIni)");
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

		protected function obtenerEmbCuentaModelo(){
			$query = mainModel::conectar()->prepare("SELECT * FROM `embarque` WHERE cuentas=0 limit 1");
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
			$idT=mainModel::generaId('bolsas_bolsero', $datos['embarque']);
			$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `cantidad_bolsas_bol`, `pago_bol`) VALUES (:IdT, :Id, :Embarque, :Fecha, 0, :Pago)");
			$query->bindParam("IdT", $idT);
			$query->bindParam("Id", $datos['id_trab']);
			$query->bindParam("Embarque", $datos['embarque']);
			$query->bindParam("Fecha", $datos['fecha']);
			$query->bindParam("Pago", $datos['pago']);
			$query->execute();
			return $query;
		}

		protected function asistenciaPlanillaEmbarque($datos){
			$idT=mainModel::generaId('bolsas_toston', $datos['Embarque']);
			$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `pago`) VALUES (:IdT, :Id, :Embarque, :Fecha, :Pago)");
			$query->bindParam(":IdT", $idT);
			$query->bindParam(":Id", $datos['Id']);
			$query->bindParam(":Embarque", $datos['Embarque']);
			$query->bindParam(":Fecha", $datos['Fecha']);
			$query->bindParam(":Pago", $datos['Pago']);
			$query->execute();
			return $query;
		}

		protected function gastoEmbarqueModelo($opc, $tipo_gasto, $id, $embarque, $peso, $precio){
			$idT=mainModel::generaId('gastos_embarque', $embarque);
			if($opc==1){
				$sql=mainModel::conectar()->prepare("INSERT INTO `gastos_embarque`(`id`,`id_embarque`, `id_gasto`, `cantidad`) VALUES ($idT, $embarque, $tipo_gasto, ($peso * $precio))");
			}elseif($opc==2){
				$sql=mainModel::conectar()->prepare("UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + ($peso * $precio)) WHERE `id`=$id");
			}elseif($opc==3){
				$sql=mainModel::conectar()->prepare("INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES ($idT, $embarque, $tipo_gasto, $precio)");
			}elseif($opc==4){
				$sql=mainModel::conectar()->prepare("UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + $precio) WHERE `id`=$id");
			}
			$sql->execute();
			return $sql;
		}

		protected function sumarGastoEmbarque($datos){
			$sql=mainModel::conectar()->prepare("UPDATE `embarque` SET `total_gastos`=`total_gastos`+ (:Cantidad) WHERE `id`=:Id");
			$sql->bindParam(":Id", $datos['Id_Embarque']);
			$sql->bindParam(":Cantidad", $datos['Cantidad']);
			$sql->execute();
			return $sql;
		}

		protected function obtenerToneladas($embarque){
			$sql=mainModel::conectar()->prepare("SELECT ROUND(sum(peso_kg)*0.001, 4) toneladas FROM `fruta` WHERE id_embarque=$embarque");
			$sql->execute();
			$ton=$sql->fetch();
			return $ton[0];
		}

		protected function agregarGasto($datos){
			$sql=mainModel::conectar()->prepare("UPDATE `embarque` SET toneladas=:Toneladas, `total_gastos`=(`total_gastos` + (:Cantidad * :Peso)) WHERE `id`=:Id");
			$sql->bindParam(":Id", $datos['embarque']);
			$sql->bindParam(":Cantidad", $datos['pago']);
			$sql->bindParam(":Peso", $datos['peso']);
			$sql->bindParam(":Toneladas", $datos['toneladas']);
			$sql->execute();
			return $sql;
		}

		protected function bolsaRegistro($datos){
			$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_diarias`(`id`,`numero`, `id_embarque`, `hora`, `fecha`, `pelador`, `id_bolsero`, id_productor) VALUES (:Id, :Numero, :Embarque, :Hora, :Fecha, :Pelador, :Bolsero, :Productor)");
			$query->bindParam("Id", $datos['id']);
			$query->bindParam("Numero", $datos['numero']);
			$query->bindParam("Embarque", $datos['embarque']);
			$query->bindParam("Pelador", $datos['pelador']);
			$query->bindParam("Bolsero", $datos['bolsero']);
			$query->bindParam("Hora", $datos['hora']);
			$query->bindParam("Fecha", $datos['fecha']);
			$query->bindParam("Productor", $datos['productor']);
			$query->execute();
			return $query;
		}

		protected function frutaProductor($datos){
			if($datos['opc']==1){
				$query=mainModel::conectar()->prepare("UPDATE `fruta` SET `peso_kg`= (`peso_kg` + :Peso),`pago`=:Pago, `saldo_abono`=:Saldo WHERE id= :Id");
				$query->bindParam(":Id", $datos['id']);
				$query->bindParam(":Peso", $datos['peso']);
				$query->bindParam(":Pago", $datos['pago']);
				$query->bindParam(":Saldo", $datos['saldo']);
			}else if($datos['opc']==2){
				$query=mainModel::conectar()->prepare("INSERT INTO `fruta`(`id`, `id_productores`, `peso_kg`, `pago`, `saldo_abono`, `id_embarque`) VALUES (:IdT, :Id, :Peso, :Pago, :Saldo, :Embarque )");
				$query->bindParam(":IdT", $datos['Id']);
				$query->bindParam(":Id", $datos['idProd']);
				$query->bindParam(":Peso", $datos['peso']);
				$query->bindParam(":Pago", $datos['pago']);
				$query->bindParam(":Saldo", $datos['saldo']);
				$query->bindParam(":Embarque", $datos['embarque']);
			}
			$query->execute();
			return $query;
		}

		protected function mostrarCard_modelo($idProd, $embActual){
			$query=mainModel::conectar()->prepare("SELECT productor_fruta.foto, productor_fruta.peso from productor_fruta INNER JOIN fruta on productor_fruta.id_fruta=fruta.id where fruta.id_productores=$idProd AND fruta.id_embarque=$embActual AND productor_fruta.peso>0");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function frutaEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("INSERT INTO `productor_fruta`(`id`, `peso`, `foto`, `id_fruta`, `fecha_compra`) VALUES (:IdT, :Peso, :Img, :Id, :Fecha)");
			$query->bindParam(":IdT", $datos['IdT']);
			$query->bindParam(":Peso", $datos['peso']);
			$query->bindParam(":Img", $datos['img']);
			$query->bindParam(":Fecha", $datos['fecha']);
			$query->bindParam(":Id", $datos['id']);
			$query->execute();
			return $query;
		}

		protected function listafrutaEmbarqueModelo($id, $fecha){
			$query= mainModel::conectar()->prepare("SELECT id_productores as id_f, concat(p.nombre,' ', p.Ap_p, ' ', p.Ap_m) as nombre, f.`peso_kg` FROM fruta f, productores p, productor_fruta pf WHERE p.id=f.id_productores AND f.id_embarque=:Id AND pf.id_fruta=f.id GROUP BY id_productores ORDER BY id_productores ASC");
			$query->bindParam(":Id", $id);
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function bolserosDiaEmbarqueModelo($datos){
			$query= mainModel::conectar()->prepare("SELECT bolsas_bolsero.`id` as id_b, id_bolsero, concat( bolseros.nombre, ' ', bolseros.Ap_p, ' ', bolseros.Ap_m) as nombre, `cantidad_bolsas_bol` FROM `bolsas_bolsero`, bolseros WHERE id_embarque= :Id AND bolseros.id = id_bolsero AND (diaUno>0 OR diaDos>0 OR diaTres>0 OR diaCuatro>0 OR diaCinco>0 ) AND bolsas_bolsero.estra!=1");

			$query->bindParam(":Id", $datos['Id']);
			//$query->bindParam(":Fecha", $datos['Fecha']);
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
			$idT=mainModel::generaId('bolsas_pelador', $datos['Embarque']);
			if($datos['opc']==1){
				$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_pelador`(`id`,`id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, pago_pe) VALUES (:Id,:Id_p, :Embarque, :Fecha, 1, :Pago)");
				$query->bindParam(":Id", $idT);
				$query->bindParam(":Id_p", $datos['Id_pelador']);
				$query->bindParam(":Embarque", $datos['Embarque']);
				$query->bindParam(":Fecha", $datos['Fecha']);
				$query->bindParam(":Pago", $datos['Pago']);
			}elseif($datos['opc']==2){
				$query=mainModel::conectar()->prepare("UPDATE `bolsas_pelador` SET `cantidad_bolsas_pe`= (`cantidad_bolsas_pe` + 1), pago_pe=pago_pe+(:Pago) WHERE `id`=:Id");
				$query->bindParam(":Id", $datos['Id']);
				$query->bindParam(":Pago", $datos['Pago']);
			}elseif($datos['opc']==3){
				$query=mainModel::conectar()->prepare("INSERT INTO `bolsas_pelador`(`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, pago_pe) VALUES (:Id, :Id_p, :Embarque, :Fecha, :Bolsas, (:Pago*:Bolsas))");
				$query->bindParam(":Id", $idT);
				$query->bindParam(":Id_p", $datos['Id_pelador']);
				$query->bindParam(":Embarque", $datos['Embarque']);
				$query->bindParam(":Fecha", $datos['Fecha']);
				$query->bindParam(":Pago", $datos['Pago']);
				$query->bindParam(":Bolsas", $datos['Bolsas']);
			}elseif($datos['opc']==4){
				$query=mainModel::conectar()->prepare("UPDATE `bolsas_pelador` SET `cantidad_bolsas_pe`= (`cantidad_bolsas_pe` + :Bolsas), pago_pe=pago_pe+(:Pago*:Bolsas) WHERE `id`=:Id");
				$query->bindParam(":Id", $datos['Id']);
				$query->bindParam(":Bolsas", $datos['Bolsas']);
				$query->bindParam(":Pago", $datos['Pago']);
			}
			$query->execute();
			return $query;//->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function addBolsaEmbarqueModelo($embarque, $bolsas){
			$query=mainModel::conectar()->prepare("UPDATE `embarque` SET `cant_bolsas_embarque`= (`cant_bolsas_embarque` + :Bolsas) WHERE id=:Embarque");
			$query->bindParam("Embarque", $embarque);
			$query->bindParam("Bolsas", $bolsas);
			$query->execute();
			return $query;
		}

		protected function finalizarEmbarqueModelo($datos){
			$query=mainModel::conectar()->prepare("UPDATE `embarque` SET `fecha_fin`=:Fecha, cant_bolsas_embarque=:Bolsas, `contenedor`=:Contenedor,`no_sello`=:Sello,`matricula`=:Matricula,`temperatura`=:Temperatura,`nombre_conductor`=:Conductor, perdida=:Perdida WHERE `id`=:Embarque");
			
			$query->bindParam("Embarque", $datos['Embarque']);
			$query->bindParam("Fecha", $datos['Fecha']);
			$query->bindParam("Bolsas", $datos['Bolsas']);
			$query->bindParam("Contenedor", $datos['Contenedor']);
			$query->bindParam("Sello", $datos['Sello']);
			$query->bindParam("Matricula", $datos['Matricula']);
			$query->bindParam("Temperatura", $datos['Temperatura']);
			$query->bindParam("Conductor", $datos['Conductor']);
			$query->bindParam("Perdida", $datos['Perdida']);
			$query->execute();
			return $query;
		}

		protected function listaBosasDiarias($embarque, $fecha){
			$sql=mainModel::conectar()->prepare("SELECT bd.id, bd.numero, bd.id_embarque, bd.fecha, bd.hora, bd.pelador, CONCAT(p.nombre, ' ', p.Ap_p, ' ', p.Ap_m) nombre, bd.valor as cantidad_bolsas_pe FROM bolsas_diarias bd, peladores p, bolsas_pelador bp WHERE bd.id_embarque=$embarque AND bd.fecha='".$fecha."' AND p.id=bd.pelador AND bp.id_pelador=bd.pelador AND bp.fecha_trabajo_pe=bd.fecha AND bp.id_embarque=bd.id_embarque ORDER BY bd.numero DESC LIMIT 11");			
			$sql->execute();
			return $sql;
		}

		protected function verResumenModelo($id, $fecha){
			$query=mainModel::conectar()->prepare("SELECT (SELECT SUM(bp.cantidad_bolsas_pe) FROM bolsas_pelador bp WHERE bp.fecha_trabajo_pe='$fecha' AND bp.id_embarque=$id) bolsas, em.total_gastos , ROUND((SELECT sum(pf.peso) FROM productor_fruta pf WHERE pf.fecha_compra='$fecha'),2) kilos FROM embarque em WHERE em.id=$id");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

		protected function listarPeladoresExtra_modelo($idEmb){
			$query=mainModel::conectar()->prepare("SELECT pelador_extra.pago,pelador_extra.trabajo, pelador_extra.id as idE, pelador_extra.id_bolsaspelador as idBP,
				peladores.id, concat(peladores.nombre,' ', peladores.Ap_p,' ', peladores.Ap_m) as nombre, pelador_extra.concepto,
				pelador_extra.fecha from bolsas_pelador INNER join pelador_extra ON bolsas_pelador.id=pelador_extra.id_bolsaspelador
				INNER JOIN peladores ON bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$idEmb  HAVING pelador_extra.trabajo !=0");
			$query->execute();
			return $query->fetchAll(PDO::FETCH_ASSOC);
		}

	}