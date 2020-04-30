<?php
	if ($peticionAjax) {
		require_once "../modelos/embarqueModelo.php";
	} else {
		require_once "./modelos/embarqueModelo.php";
	}

	class embarqueControlador extends embarqueModelo{

		public function crearEmbarqueControlador(){
			$id=$_POST['id'];
			$fecha=mainModel::limpiar_cadena($_POST['fecha']);

			$datos=[
				"Id"=>$id,
				"FechaIni"=>$fecha,
			];

			$sql=embarqueModelo::crearEmbarqueModelo($datos); 

			return $sql;
		}

		public function seleccionEmbarqueControlador(){
			$id = $_POST['id'];
			$sql= embarqueModelo::seleccionEmbarqueModelo($id);
			return $sql;
		}

		public function obtenerEmbarqueControlador(){
			
			return embarqueModelo::obtenerEmbarqueModelo();
		}

		public function asistenciaEmbarqueControlador(){
			$tipo=$_POST['tipo'];
			$id=$_POST['id'];
			$embarque=mainModel::limpiar_cadena($_POST['embarque']);
			$fecha=mainModel::limpiar_cadena($_POST['fechaDia']);

			/*if($tipo==1){
				$query = mainModel::ejecutar_consulta_simple("SELECT id FROM `bolsas_pelador` WHERE fecha_trabajo_pe=$fecha AND id_pelador=$id AND id_embarque=$embarque");
			}else{
				$query = mainModel::ejecutar_consulta_simple("SELECT id FROM `bolsas_bolsero` WHERE fecha_trabajo_bol=$fecha AND id_bolsero=$id AND id_embarque=$embarque");
			}
			
			$row = $query->fetch();

			if($row->rowCount()>=1){
				$sql=null;
			}else{*/
				$datos=[
					"tipo"=>$tipo,
					"id_trab"=>$id,
					"embarque"=>$embarque,
					"fecha"=>$fecha
				];

				$sql=embarqueModelo::asistenciaEmbarqueModelo($datos);
			//}

			return $sql;
		}

		public function frutaEmbarqueControlador(){
			$id = $_POST['id'];
			$peso = $_POST['peso'];
			$embarque = $_POST['embarque'];
			$fecha = $_POST['fecha'];
			$img = $_POST['img'];

			$datos = [
				"idProd"=> $id,
				"peso"=> $peso,
				"embarque"=> $embarque,
				"fecha"=> $fecha,
				"img"=>$img
			];

			$sql = embarqueModelo::frutaEmbarqueModelo($datos);

			return $sql;
		}

		public function listafrutaEmbarqueControlador(){
			$id_embarque = $_POST['id'];

			$sql=embarqueModelo::listafrutaEmbarqueModelo($id_embarque);

			return $sql;
		}

		public function peladoresDiaEmbarqueControlador(){
			$id_embarque = $_POST['embarque'];
			$fecha = $_POST['fechaDia'];

			$datos=[
				"Id"=>$id_embarque,
				"Fecha" => $fecha
			];

			$sql = embarqueModelo::peladoresDiaEmbarqueModelo($datos);

			return $sql;
		}

		public function bolserosDiaEmbarqueControlador(){
			$id_embarque = $_POST['embarque'];
			$fecha = $_POST['fechaDia'];

			$datos=[
				"Id"=>$id_embarque,
				"Fecha" => $fecha
			];

			$sql = embarqueModelo::bolserosDiaEmbarqueModelo($datos);

			return $sql;
		}

		public function finalizarDiaEmbarqueControlador(){
			$id_embarque=$_POST['id'];

			$sql=embarqueModelo::finalizarDiaEmbarqueModelo($id_embarque);

			return $sql;
		}

		public function addBolsaEmbarqueControlador(){
			$pago=10;
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$pelador_id=$_POST['id_p'];
			$bolsero_id=$_POST['id_b'];
			$productor_id=$_POST['id_prod'];

			$datos=[
				"Embarque"=>$embarque,
				"Fecha"=> $fecha,
				"Id_pelador"=> $pelador_id,
				"Id_bolsero"=> $bolsero_id,
				"Pago"=>$pago
			];
			
			$sql_e=embarqueModelo::addBolsaEmbarqueModelo($datos);
			$sql_p=embarqueModelo::addBolsaPeladorEmbarqueModelo($datos);
			$sql_b=embarqueModelo::addBolsaBolseroEmbarqueModelo($datos);

			return $sql_p;
		}

		public  function finalizarEmbarqueControlador(){
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$sello=mainModel::limpiar_cadena(strtoupper($_POST['sello']));
			$matricula=mainModel::limpiar_cadena(strtoupper($_POST['matricula']));
			$contenedor =mainModel::limpiar_cadena(strtoupper($_POST['contenedor']));
			$temperatura = $_POST['temperatura'];
			$conductor =mainModel::limpiar_cadena(strtoupper($_POST['conductor']));

			$datos=[
				"Embarque"=>$embarque,
				"Fecha"=> $fecha,
				"Sello"=> $sello,
				"Matricula"=> $matricula,
				"Temperatura" => $temperatura,
				"Contenedor" => $contenedor,
				"Conductor" => $conductor
			];

			$sql=embarqueModelo::finalizarEmbarqueModelo($datos);

			return $sql;
		}
	}