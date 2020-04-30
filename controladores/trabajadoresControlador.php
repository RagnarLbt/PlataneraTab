<?php
	if ($peticionAjax) {
		require_once "../modelos/trabajadoresModelo.php";
	} else {
		require_once "./modelos/trabajadoresModelo.php";
	}

	class trabajadoresControlador extends trabajadoresModelo{


		public function registroTrabajadorControlador(){
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
            $tipo=mainModel::limpiar_cadena($_POST['tipo']);
            
			$datos=[
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm,
				"opc"=>$tipo
			];

			$sql=trabajadoresModelo::registroTrabajadorModelo($datos);

			return $sql;
		}

		public function actualizarTrabajadorControlador(){
			$id=mainModel::limpiar_cadena($_POST['id']);
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
			$apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));
			$tipo=mainModel::limpiar_cadena($_POST['tipo']);

			$datos=[
				"Id" => $id,
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm,
				"opc"=>$tipo
			];

			$sql=trabajadoresModelo::actualizarTrabajadorModelo($datos);			
			return $sql;
		}

		public function eliminarTrabajadorControlador(){
			$id=mainModel::limpiar_cadena($_POST['id']);
			$tipo=mainModel::limpiar_cadena($_POST['tipo']);

			$datos=[
				"Id" => $id,
				"opc"=>$tipo
			];

			$sql=trabajadoresModelo::eliminarTrabajadorModelo($datos);			
			return $sql;
		}

		public function listaPeladorControlador(){
			$sql=trabajadoresModelo::listaPeladoresModelo();
			return $sql;
		}

		public function listaBolseroControlador(){
			$sql=trabajadoresModelo::listaBolserosModelo();
			return $sql;
		}

		public function listaGeneralControlador(){
			$sql=trabajadoresModelo::listaGeneralModelo();
			return $sql;
		}

	}