<?php
	if ($peticionAjax) {
		require_once "../modelos/empresaModelo.php";
	} else {
		require_once "./modelos/empresaModelo.php";
	}

	class empresaControlador extends empresaModelo{

		public function modificarPrecioControlador(){
			$precio = $_POST['precio-reg'];

			$alerta=[
				"Alerta"=>"simple",
				"Titulo"=>"Ocurrio un error inesperado",
				"Texto"=>"El nombre de usuario y contraseña no son correctos",
				"Tipo"=>"error"
			];

			return mainModel::sweet_alert($alerta);
		}

		public function addGastoControlador(){
			$gasto = $_POST['gasto-reg'];

			$alerta=[
				"Alerta"=>"simple",
				"Titulo"=>"Ocurrio un error inesperado",
				"Texto"=>"El nombre de usuario y contraseña no son correctos",
				"Tipo"=>"error"
			];

			return mainModel::sweet_alert($alerta);
		}
	}