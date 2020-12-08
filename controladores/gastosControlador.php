<?php
	if ($peticionAjax) {
		require_once "../modelos/gastosModelo.php";
	} else {
		require_once "./modelos/gastosModelo.php";
	}

	class gastosControlador extends gastosModelo{

		public function obtenerEmbarqueControlador(){
			return gastosModelo::obtenerEmbarqueModelo();
		}

		public function buscarGastosControlador(){
			$id = $_POST['id'];
			$sql= gastosModelo::seleccionEmbarqueModelo($id);
			return $sql;
		}

		public function listaGastosControlador(){
			$sql= gastosModelo::listaGastosModelo();
			return $sql;
		}

		public function listarTodosLosGastosControlador(){
			$sql=gastosModelo::listaTodosLosGastosModelo();
			return $sql;
		}

		public function registroGastosControlador(){
			$embarque = $_POST['embarque'];
			$id_gasto = $_POST['gasto'];
			$cantidad = $_POST['cantidad'];
			$concepto = strtoupper($_POST['concepto']);
			$kilos = $_POST['kilos'];

			if($id_gasto!=22){
				$sql=mainModel::ejecutar_consulta_simple("CALL regGastoEmbarque($embarque, $id_gasto, $cantidad, $kilos)");
				if($sql->rowCount()>=1){
					return "OK";
				}else{
					return $sql;
				}
			}else{
				$sql=mainModel::ejecutar_consulta_simple("CALL regGastoEmb($embarque, $id_gasto, $cantidad, '$concepto')");
				if($sql->rowCount()>=1){
					return "OK";
				}else{
					return $sql;
				}
			}
		}

		public function listaGastosRegistradosControlador(){
			$id=$_POST['id'];

			if(isset($_POST['con']) && $_POST['con']==1){
				$sql= gastosModelo::listaGastosConsultas($id);
			}else{
				$sql= gastosModelo::listaGastosRegistrados($id);
			}
			return $sql;
		}

		public function getPrecioControlador(){
			$sql=mainModel::ejecutar_consulta_simple("SELECT id_precio, cantidad, pago_bolsero, pago_pelador FROM `precio_compra` ORDER BY id_precio DESC LIMIT 1");
			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function updatePrecioControlador(){
			$id=$_POST['id'];
			$cantidad=$_POST['cantidad'];
			$pelador=$_POST['pelador'];
			$bolsero=$_POST['bolsero'];

			$sql=gastosModelo::updatePrecioModelo($id, $cantidad, $pelador, $bolsero);

			return $sql;
		}

		public function registroGastoNuevoControlador(){
			$nombre=strtoupper($_POST['gasto']);

			$sql=mainModel::ejecutar_consulta_simple("INSERT INTO `gastos`(`nombre`) VALUES ('".$nombre."')");

			return $sql;
		}

		public function eliminarTipoGastoControlador(){
			$id=$_POST['id_gasto'];

			$sql=mainModel::ejecutar_consulta_simple("DELETE FROM `gastos` WHERE `id_gasto`=$id");

			return $sql;
		}

		public function modificarTipoGastoControlador(){
			$id=$_POST['id'];
			$nombre=strtoupper($_POST['nombre']);

			$sql=gastosModelo::modificarTipoGastoModelo($id, $nombre);

			return $sql;
		}

		public function modificarGastoControlador(){
			$id=$_POST['id'];
			$cantidad=$_POST['cantidad'];
			$cantidad_new=$_POST['cantidad_new'];
			$embarque=$_POST['embarque'];

			$sql=mainModel::ejecutar_consulta_simple("CALL modGastoEmbarque($id, $embarque, $cantidad, $cantidad_new)");

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}
		}

		public function eliminarGastoControlador(){
			$id=$_POST['id'];
			$cantidad=$_POST['cantidad'];
			$embarque=$_POST['embarque'];

			$sql=mainModel::ejecutar_consulta_simple("CALL elimGastoEmbarque($id, $cantidad, $embarque)");
			
			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}

		}
		

	}