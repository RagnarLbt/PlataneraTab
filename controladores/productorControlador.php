<?php
	if ($peticionAjax) {
		require_once "../modelos/productorModelo.php";
	} else {
		require_once "./modelos/productorModelo.php";
	}

	class productorControlador extends productorModelo{

		public function registroProductorControlador(){
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));

            $datos=[
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm
			];

			$sql=productorModelo::registroProductorModelo($datos);

			return $sql;
		}

		public function actualizarProductorControlador(){
			$id=mainModel::limpiar_cadena($_POST['id']);
			$nombre=mainModel::limpiar_cadena(strtoupper($_POST['nombre']));
			$app=mainModel::limpiar_cadena(strtoupper($_POST['app']));
            $apm=mainModel::limpiar_cadena(strtoupper($_POST['apm']));

            $datos=[
            	"Id"=>$id,
				"Nombre"=>$nombre,
				"ApP"=>$app,
				"ApM"=>$apm
			];

			$sql=productorModelo::actualizarProductorModelo($datos);

			return $sql;
		}

		public function eliminarProductorControlador(){
			$id = mainModel::limpiar_cadena($_POST['id']);
			
			$sql=productorModelo::eliminarProductorModelo($id);
			return $sql;
		}

		public function listaProductorControlador(){
			$sql=productorModelo::listaProductorModelo();
			return $sql;
		}

		public function listaOidenadaProductorControlador(){
			$sql=productorModelo::listaOrdenadaProductorModelo();
			return $sql;
		}

	}