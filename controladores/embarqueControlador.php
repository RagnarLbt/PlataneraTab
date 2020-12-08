<?php
	if ($peticionAjax) {
		require_once "../modelos/embarqueModelo.php";
		require_once "../modelos/imprimirTicket.php";
		require_once "../vistas/assets/pdf/vendor/autoload.php";
	} else {
		require_once "./modelos/embarqueModelo.php";
		require_once "./modelos/imprimirTicket.php";
		//require_once "../vistas/assets/pdf/vendor/autoload.php";
	}

	class embarqueControlador extends embarqueModelo{

		public function crearEmbarqueControlador(){
			$id=$_POST['id'];
			$fecha=mainModel::limpiar_cadena($_POST['fecha']);

			$datos=[
				"Id"=>$id,
				"FechaIni"=>$fecha
			];

			$sql=embarqueModelo::crearEmbarqueModelo($datos);

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return "ErrorRegistro";
			}
		}

		public function seleccionEmbarqueControlador(){
			$id = $_POST['id'];
			$sql= embarqueModelo::seleccionEmbarqueModelo($id);

			//self::pdfFinalizar();

			return $sql;
		}

		public function obtenerEmbCuentaControlador(){
			return embarqueModelo::obtenerEmbCuentaModelo();
		}

		public function obtenerEmbarqueControlador(){
			
			return embarqueModelo::obtenerEmbarqueModelo();
		}

		public function asistenciaEmbarqueControlador(){
			$id=$_POST['id'];
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fechaDia'];
			$pago_b=$_POST['pago'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regTrabajoBo($embarque, $id, '$fecha', $pago_b)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function frutaEmbarqueControlador(){
			$id = $_POST['id'];
			$peso = $_POST['peso'];
			$embarque = $_POST['embarque'];
			$fecha = $_POST['fecha'];
			$base64 = $_POST['img'];
			$hora= date("H:i:s");
			$hora_img= date("H-i-s");
			$pago = $_POST['precio'];

			if($id==0){
				return "ErrorProductor0";
			}else{
				//Verificar si existe una foto
				if($base64==null || $base64=='null'){
					$ruta2='http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png';
				}else{
					//Eliminamos data:image/png; y base64
					//Aquí va $imagen=$_POST[imagen] del ajax
					list(,$base64)=explode(';', $base64);
					list(,$base64)=explode(',', $base64);
					$data=base64_decode($base64);

					$image= imagecreatefromstring($data);

					$nombre=$fecha.'-'.$hora_img.'-'.$embarque.'_'.$id;

					//Guardamos la foto en la carpeta  #Embarque-#Productor-Fecha.png 
					imagepng($image, $nombre.'.png');
					imagedestroy($image);

					//Creamos el texto a la imagen aquí-------------------

					header('Content-Type: image/png');

					$image = imagecreatefrompng($nombre.'.png');
					$color = imagecolorallocate($image, 255, 255, 255);
					$font_path = __DIR__.'\arial.ttf';
					$text='Prod:'.$id.' Emb:'.$embarque.' '.$fecha.' '.$hora;
					imagettftext($image, 10, 0, 430, 457, $color, $font_path, $text);
					$ruta='../vistas/assets/img/'.$nombre.'.png';
					imagepng($image,$ruta );
					unlink($nombre.'.png');
					imagedestroy($image);
					$ruta2='http://localhost/PLATANERATAB/vistas/assets/img/'.$nombre.'.png';
				}

				$sql=mainModel::ejecutar_consulta_simple("CALL regFruta($id, $embarque, $peso, '$fecha', '$ruta2', $pago, '$hora')");

				if($sql->rowCount()>=1){
					return "OK1null";
			
				}else{
					return "NULL";
				}
			}
		}

		//Imprimir Etiqueta
		public function imprimirEtiqueta($prod, $dia, $bol, $pel, $h, $f, $bolsa){
			$impTermica=new imprimirTicket();

			switch ($dia) {
				case 0: $dia='A'; break;
				case 1: $dia='B'; break;
				case 2: $dia='C'; break;
				case 3: $dia='D'; break;
				case 4: $dia='E'; break;
			}

			if($prod<10){
				$prod='0'.$prod;
			}

			$datosEtiqueta=[
				"DIA"=>$dia,
				"PRODUCTOR"=>$prod,
				"BOLSERO"=>$bol,
				"PELADOR"=>$pel,
				"HORA"=>$h,
				"FECHA"=>$f,
				"BOLSA"=>$bolsa
			];
			//imprimimos el etiqueta
			//$impTermica->imprimir($datosEtiqueta);

			return $impTermica->imprimir($datosEtiqueta);
			//return $datosEtiqueta;
		}

		public function registroPlanillaToston(){
			$id=$_POST['id_planilla'];
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$pago=$_POST['pago'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regTrabajoPT($embarque, '$fecha', $pago, $id)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}			
		}
		public function listaRend(){
			$idProd=$_POST['idPro'];
			$embActual=$_POST['idEmb'];
			$sql=mainModel::ejecutar_consulta_simple("SELECT round(fruta.cant_bolsas/(fruta.peso_kg*0.001), 2) as rend from fruta
            where fruta.id_embarque =$embActual AND fruta.id_productores=$idProd
            GROUP by fruta.id_productores");
			 return $sql->fetchAll(PDO::FETCH_ASSOC);


		}
		public function mostrarCard_controlador(){
			$idProd=$_POST['idProd'];
			$embActual=$_POST['embActual'];
			$sql=embarqueModelo::mostrarCard_modelo($idProd, $embActual);
			return $sql;
		}

		public function listafrutaEmbarqueControlador(){
			$id_embarque = $_POST['id'];
			$fecha= $_POST['fecha'];

			$sql=embarqueModelo::listafrutaEmbarqueModelo($id_embarque, $fecha);

			return $sql;
		}

		public function bolserosDiaEmbarqueControlador(){
			$id_embarque = $_POST['embarque'];
			$fecha = $_POST['fechaDia'];
			
			$datos=[
				"Id"=>$id_embarque
				//"Fecha" => $fecha
			];


			$sql = embarqueModelo::bolserosDiaEmbarqueModelo($datos);
			return $sql;
		}

		public function finalizarDiaEmbarqueControlador(){
			$id_embarque=$_POST['id'];

			$sql=embarqueModelo::finalizarDiaEmbarqueModelo($id_embarque);

			return $sql;
		}

		/*----------  Sumar multiples bolsas al embarque  ----------*/
		public function addBolsasPeladorEmbarqueControlador(){
			$pago=0;
			$pelador_id=$_POST['id_p'];
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$num=$_POST['bolsaNo'];
			$pago_p=$_POST['pagoP'];
			$bolsas=$_POST['bolsas'];
			$productor=$_POST['productor'];

			$sql=mainModel::ejecutar_consulta_simple("CALL sumeerMultiplesBolsas($embarque, $pelador_id , $productor , '$fecha', $num, $pago_p, $bolsas)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}

			/*Buscar registro en la tabla bolsas_pelador
			$busPel=mainModel::ejecutar_consulta_simple("SELECT id FROM bolsas_pelador WHERE id_embarque=$embarque AND id_pelador=$pelador_id AND fecha_trabajo_pe='".$fecha."'");
			
			if($busPel->rowCount() >= 1){
				$row=$busPel->fetch();

				//Comprobar el estado de trabajo
				$estadoPel=mainModel::ejecutar_consulta_simple("SELECT estado FROM bolsas_pelador WHERE id=$row[0]");
				$esta=$estadoPel->fetch();
				
				if($esta[0]==0){
					//Insertamos el registro
					$dat=[
						"Embarque"=>$embarque,
						"Id"=>$row[0],
						"Pago"=>$pago_p,
						"Bolsas"=>$bolsas,
						"opc"=>4
					];

					$sql_p=embarqueModelo::addBolsaPeladorEmbarqueModelo($dat);

					if($sql_p->rowCount()>=1){
						$bolsasEmbarque=embarqueModelo::addBolsaEmbarqueModelo($embarque, $bolsas);
						$cantidad=$pago_p*$bolsas;
						return self::actualizarGastosEmbarque(2, $embarque, 2, 0,  $cantidad);
					}else{
						return "ErrorRegistrarPeladorBolsas1";
					}
				}else{
					return "Error";
				}

			}else{

				//Insertamos el registro
					$dat=[
						"Embarque"=>$embarque,
						"Fecha"=> $fecha,
						"Id_pelador"=> $pelador_id,
						"Pago"=>$pago_p,
						"Bolsas"=>$bolsas,
						"opc"=>3
					];

					$sql_p=embarqueModelo::addBolsaPeladorEmbarqueModelo($dat);
					
					if($sql_p->rowCount()>=1){
						$bolsasEmbarque=embarqueModelo::addBolsaEmbarqueModelo($embarque, $bolsas);
						$cantidad=$pago_p*$bolsas;
						return self::actualizarGastosEmbarque(2, $embarque, 2, 0,  $cantidad);
					}else{
						return "ErrorRrgistrarPeladorBolsas";
					}
			}*/
		}

		public function addBolsaEmbarqueControlador(){
			$pago=0;
			$bolsero_id=strtoupper($_POST['id_b']);
			$pelador_id=$_POST['id_p'];
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$hora=date("h:i:s A");
			$productor_id=$_POST['id_prod'];
			$num=$_POST['bolsaNo'];

			$dia=$_POST['dia'];

			$pago_b=$_POST['pagoB'];
			$pago_p=$_POST['pagoP'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regBolsas($embarque, $pelador_id, $productor_id, '$bolsero_id', '$fecha', '$hora', $num, $pago_p)");

			if($sql->rowCount()>=1){
				self::imprimirEtiqueta($productor_id, $dia, $bolsero_id, $pelador_id, $hora, $fecha, ($num+1));
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function listaBosasDia($embarque, $fecha){
			
			$datos=embarqueModelo::listaBosasDiarias($embarque, $fecha);
			$row=$datos->fetch();

			$html='';
			if($datos->rowCount()>=1){
				for ($i=0; $i < 1; $i++) {
				$html.='<div class="card col-sm-6">
					<div class="list-inline-item text-dark alert-link mt-3 mb-3">
						<div class="col-sm-12 d-flex justify-content-center mb-0">
							<p class="mb-1" style="font-size: 50px;">Pelador-Bolsas</p>
						</div>
						<div class="col-sm-12 d-flex justify-content-center">
							<h1 class="mb-1">'.$row['pelador'].'-'.$row['cantidad_bolsas_pe'].'</h1>
						</div>
						<h1 style="font-size:60px;" class="col-sm-12 text-center font-weight-bold">'.$row['nombre'].'</h1>
						<p></p>
						<p class="col-sm-12 text-center" style="font-size: 40px;">'.$row['hora'].'</p>
					</div>
				</div>';
				}
				$html.='<div class="col-sm-6 pasado-tablero pl-0 pr-0 mt-1 ml-3">
					<ul class="list-inline">';

				foreach ($datos as $row) {
						$html.='<li class="border list-inline-item rounded mt-1 bg-white text-dark col-sm-5">
							<p class="list-inline-item border" >
								<div class="d-flex justify-content-between">
									<h4 class="text-center font-weight-bold">Pel. #'.$row['pelador'].'</h4>
									<h4 class="text-right font-weight-bold">Total. '.$row['cantidad_bolsas_pe'].'</h4>
								</div>'.$row['nombre'].'
								<div class="d-flex justify-content-between">
									<p class="text-center font-weight-bold">Bolsa # '.$row['numero'].'</p>
									<p class="text-right font-weight-bold">'.$row['hora'].'</p>
								</div>
							</p>
						</li>';
				}
					$html.='</ul>
					</div>';
			}

			echo $html;
		}

		public function obtenerBolsasDiaControlador(){
			$embarque=$_POST['id'];
			$fecha=$_POST['fecha'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT bd.`id`, bd.`numero`, bd.`id_embarque`, bd.fecha, bd.`hora`, bd.`pelador`, bd.`id_bolsero`, bd.id_productor, concat(p.nombre, ' ', p.Ap_p) nombre FROM bolsas_diarias bd, peladores p WHERE bd.id_embarque=$embarque AND bd.fecha='$fecha' AND p.id=bd.pelador ORDER BY bd.numero DESC");

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}
		public function listaPelador(){
			$idEmb=$_POST['emb'];
			$fech=$_POST['fecha'];
			$sql=mainModel::ejecutar_consulta_simple("SELECT IFNULL(bolsas_pelador.estado, 0) estado, peladores.id, CONCAT(peladores.nombre, ' ', peladores.Ap_p, ' ', peladores.Ap_m) as nombre, IFNULL(bolsas_pelador.cantidad_bolsas_pe,0) as bolsas FROM peladores LEFT JOIN bolsas_pelador on peladores.id=bolsas_pelador.id_pelador and bolsas_pelador.id_embarque=$idEmb and bolsas_pelador.fecha_trabajo_pe='$fech' where peladores.estado=1  ORDER BY peladores.id ASC");
			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}
		public function actualizarBolsasDiaControlador(){
			$id=$_POST['id'];
			$idPel=$_POST['idPel'];
			$idBol=strtoupper($_POST['idBol']);
			$idProd=$_POST['idPrd'];
			$idActPel=$_POST['actPel'];
			$idActBol=strtoupper($_POST['actBol']);
			$idActProd=$_POST['actProd'];
			$fecha=$_POST['fecha'];
			$embarque=$_POST['embarque'];
			$pagoBol=$_POST['pagoB'];
			$pagoPel=$_POST['pagoP'];

			if($idProd != $idActProd){
				$buscProd=mainModel::ejecutar_consulta_simple("SELECT id FROM fruta WHERE id_embarque=$embarque AND id_productores=$idProd");
				if($buscProd->rowCount()>=1){
					$actFruta=mainModel::ejecutar_consulta_simple("UPDATE fruta SET cant_bolsas=cant_bolsas-1 WHERE id_embarque=$embarque AND id_productores=$idActProd");
					if($actFruta->rowCount()>=1){
						$actFrutaMas=mainModel::ejecutar_consulta_simple("UPDATE fruta SET cant_bolsas=cant_bolsas+1 WHERE id_embarque=$embarque AND id_productores=$idProd");
					}
				}else{
					return "ProductorNoEncontrado";
				}
			}

			if($idActPel != $idPel){
				$actPel=mainModel::ejecutar_consulta_simple("UPDATE bolsas_pelador SET cantidad_bolsas_pe=(cantidad_bolsas_pe-1) WHERE id_embarque=$embarque AND fecha_trabajo_pe='".$fecha."' AND id_pelador=$idActPel");

				$busExistP=mainModel::ejecutar_consulta_simple("SELECT id FROM bolsas_pelador WHERE id_embarque=$embarque AND fecha_trabajo_pe='$fecha' AND id_pelador=$idPel");

				if($busExistP->rowCount()>=1){
					$actPelador=mainModel::ejecutar_consulta_simple("UPDATE bolsas_pelador SET cantidad_bolsas_pe=(cantidad_bolsas_pe+1) WHERE id_embarque=$embarque AND fecha_trabajo_pe='".$fecha."' AND id_pelador=$idPel");
				}else{
					$idT=mainModel::generaId('bolsas_pelador', $embarque);
					$inserPel=mainModel::ejecutar_consulta_simple("INSERT INTO bolsas_pelador (`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`) VALUES ($idT, $idPel, $embarque, $fecha, 1, $pagoPel)");
				}
			}

			$actBolsa=mainModel::ejecutar_consulta_simple("UPDATE `bolsas_diarias` SET `pelador`=$idPel,`id_bolsero`='$idBol',`id_productor`=$idProd WHERE `id`=$id");

			if($actBolsa->rowCount()>=1){
				return "OK";
			}else{
				return "Error";
			}

		}

		public function finalizarEmbarqueControlador(){
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$sello=strtoupper($_POST['sello']);
			$matricula=strtoupper($_POST['matricula']);
			$contenedor =strtoupper($_POST['contenedor']);
			$temperatura = $_POST['temperatura'];
			$conductor =strtoupper($_POST['conductor']);
			$noBolsas=$_POST['bolsas'];
			$perdida=$_POST['perdida'];
			$rendimiento=$_POST['rendimiento'];
			$pago_p=$_POST['pagoPel'];
			$bolsasFinal=$_POST['bolsasFinal'];
			$bolsasToston=$_POST['bolTos'];

			$aguinaldo=(3*$noBolsas);

			$sql=mainModel::ejecutar_consulta_simple("CALL finalizarEmbarque($embarque, '$fecha', '$sello', '$matricula', '$contenedor', '$temperatura', '$conductor', $bolsasFinal, $perdida, $aguinaldo, $bolsasToston)");

			if($sql->rowCount()>=0){
				return "Ok";
			}else{
				return $sql;
			}
		}

		public function addBolsasExtraControlador(){
			$embarque=$_POST['id'];
			$nombre=strtoupper($_POST['nombre']);
			$apellidos=strtoupper($_POST['apellidos']);
			$edad=$_POST['edad'];
			$tel=$_POST['tel'];
			$dir=strtoupper($_POST['dir']);
			$cuenta=strtoupper($_POST['cuenta']);
			$acti=strtoupper($_POST['acti']);
			$pago=$_POST['pago'];
			$fecha=$_POST['fecha'];


			$sql=mainModel::ejecutar_consulta_simple("CALL regBOLExtra(1, $embarque, '$nombre' , '$apellidos', $edad, '$tel', '$dir', '$cuenta', '$acti', $pago, '$fecha', 0)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}			
		}

		public function listaBolsasExtraControlador(){
			$embarque=$_POST['id'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT id, nombre, apellidos, edad, telefono, direccion, cuenta, actividad, pago, fecha FROM `bolsero_extra` WHERE id_embarque=$embarque AND pago>0 AND nombre!=''");

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function modBolsasExtraControlador(){
			$id=$_POST['id'];
			$embarque=$_POST['embarque'];
			$nombre=strtoupper($_POST['nombre']);
			$apellidos=strtoupper($_POST['apellidos']);
			$edad=$_POST['edad'];
			$tel=$_POST['tel'];
			$dir=strtoupper($_POST['dir']);
			$cuenta=strtoupper($_POST['cuenta']);
			$actividad=strtoupper($_POST['acti']);
			$pago=$_POST['pago'];
			$pago_1=$_POST['pago_1'];
			$fecha=$_POST['fecha'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regBOLExtra(2, $embarque, '$nombre' , '$apellidos', $edad, '$tel', '$dir', '$cuenta', '$actividad', $pago, '$fecha', $id)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function deleteBolsasExtraControlador(){
			$id=$_POST['id'];
			$pago=$_POST['pago'];
			$embarque=$_POST['embarque'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regBOLExtra(3, $embarque, '' , '', 0, '', '', '', '', $pago, '', $id)");

			if($sql->rowCount()>=1){

				return "OK1null";

			}else{
				return $sql;
			}
		}

		public function extraBolsasControlador(){
			$embarque=$_POST['embarque'];
			$fecha=$_POST['fecha'];
			$idBolsero=$_POST['id'];
			$trabajo=strtoupper($_POST['act']);
			$pago=$_POST['pago'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regTrabajoExtra(1, $embarque, $idBolsero, '$trabajo', $pago, '$fecha', 0, 0)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function listaBolserosOtrosControlador(){
			$id=$_POST['id'];
			$fecha=$_POST['fecha'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT bb.id, bb.id_bolsero, extra.id as idExtra, concat(b.nombre,' ',b.Ap_p,' ',b.Ap_m) nombre, extra.fecha, extra.pago, extra.descripcion actividad FROM bolsas_bolsero bb, bolseros b, extra WHERE bb.id_embarque=$id AND extra.fecha='$fecha' AND b.id=bb.id_bolsero AND extra.id_bolsas_bolsero=bb.id AND extra.pago>0");
			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function modBolseroOtroControlador(){
			$id=$_POST['id'];
			$idE=$_POST['idE'];
			$embarque=$_POST['embarque'];
			//$id_bolsero=$_POST['bolsero'];
			$acti=strtoupper($_POST['acti']);
			$pago=$_POST['pago'];
			//$pago_=$_POST['pago_'];
			$fecha=$_POST['fecha'];
			$new_cantidad=0;

			$sql=mainModel::ejecutar_consulta_simple("CALL regTrabajoExtra(2, $embarque, 0, '$acti', $pago, '$fecha', $idE, $id)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function deleteBolseroOtroControlador(){
			$id=$_POST['id'];
			$idE=$_POST['idE'];
			$embarque=$_POST['embarque'];
			$pago=$_POST['pago'];
			$fecha=$_POST['fec'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regTrabajoExtra(3, $embarque, 0, '', $pago, '$fecha', $idE, $id)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}

		}

		//Falta Actualizar Cuenta Banco
		public function addPrestamoControlador(){
			$idProd=$_POST['id'];
			$embarque=$_POST['embarque'];
			$tipo=$_POST['tipo'];
			$cantidad=$_POST['cantidad'];
			$pagos=$_POST['pagos'];

			$sql=mainModel::ejecutar_consulta_simple("CALL addPrestamo($tipo, $idProd, $embarque, $cantidad, $pagos)");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function getPrestamoControlador(){
			$id=$_POST['idProd'];

			$datos=mainModel::ejecutar_consulta_simple("SELECT prestamos.id, fruta.id, no_pagos_fungicida, no_pagos_fertilizante, no_pagos_prestamo, (saldo_fertilizante+saldo_prestamo+saldo_fungicida) cantidad, saldo_fertilizante sfer, saldo_fungicida sfun, saldo_prestamo sp, abono_cantidad_fertilizante abono_fer, abono_cantidad_fungicida abono_fun, abono_cantidad_prestamo abono_p FROM prestamos, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=$id ORDER BY CAST(prestamos.id as int) DESC LIMIT 1");

			if($datos->rowCount()>=1){
				return $datos->fetchAll(PDO::FETCH_ASSOC);
			}else{
				return "Error";
			}

		}

		public function addAbonoControlador(){
			$id=$_POST['id'];
			$embarque=$_POST['embarque'];
			$tipo=$_POST['tipo'];
			$cantidad=$_POST['cantidad'];

			$sql=mainModel::ejecutar_consulta_simple("CALL addAbono($id, $embarque, $tipo, $cantidad)");

			if ($sql->rowCount()>=1) {
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function verResumenControlador(){
			$id = $_POST['id'];
			$fecha = $_POST['fecha'];
			$sql= embarqueModelo::verResumenModelo($id, $fecha);
			return $sql;
		}

		public function actualizarGastosEmbarque($fg, $embarque, $tipo_gasto, $peso,  $pago){
			//Si es gasto-registro de Fruta fg==1
			if($fg==1){
				$act=2;
				$inse=1;
			}elseif($fg>=2){
			//Si es gasto de prestamo u otro tipo de fg==2
				$act=4;
				$inse=3;
			}
			//Registrar el gasto en la tabla Gastos
			//Buscamos si ya existe el registro
			$buscarGasto=mainModel::ejecutar_consulta_simple("SELECT `id` FROM `gastos_embarque` WHERE `id_embarque`=$embarque and `id_gasto`=$tipo_gasto");

			if($buscarGasto->rowCount()>=1){
				//Si existe actualizamos
				$idg=$buscarGasto->fetch();
				$gasto_embarque=embarqueModelo::gastoEmbarqueModelo($act, $tipo_gasto, $idg['id'], $embarque, $peso, $pago);

				if($gasto_embarque->rowCount()>=1){
					//Si es gasto-registro de Fruta fg==1
					if($fg==1){
						$toneladas=embarqueModelo::obtenerToneladas($embarque);
						$regEmbasrque=[
							"embarque"=> $embarque,
							"pago"=> $pago,
							"peso"=> $peso,
							"toneladas"=>$toneladas
						];
						//Sumar el gasto y toneladas de fruta al embarque
						$gasto=embarqueModelo::agregarGasto($regEmbasrque);

						if($gasto->rowCount()>=1){

							$cantidad=$pago*$peso;

							$actCuenta=mainModel::ejecutar_consulta_simple("CALL update_pesos($embarque, $cantidad)");

							if($actCuenta->rowCount()>=1){
								echo "OK1";
							}else{
								echo "OK";
							}

						}else{
							echo "ErrorGastoToneladas";
						}
					}elseif($fg==2){
						//Actualizamos la cantidad total de gastos del embarque
						$sumaGasto=[
							"Id_Embarque"=>$embarque,
							"Cantidad"=>$pago
						];

						$sumaGastoEmb=embarqueModelo::sumarGastoEmbarque($sumaGasto);

						if($sumaGastoEmb->rowCount()>=1){
							/*$embPesos='GE'.'$embarque';
							$nuscCuPes=mainModel::ejecutar_consulta_simple("SELECT pesos.* FROM pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id WHERE cuenta_pesos.id_emb=$embarque ORDER BY pesos.id DESC LIMIT 1");
							$datosPesos=$nuscCuPes->fetch();

							if($datosPesos['concepto']==$embPesos){
								$datosPesos=$nuscCuPes->fetch();
							}else{
								$insertarPesos=mainModel::ejecutar_consulta_simple("INSERT INTO pesos (id_)");
							}*/

							$actCuenta=mainModel::ejecutar_consulta_simple("CALL update_pesos($embarque, $pago)");

							if($actCuenta->rowCount()>=1){
								echo "OK1";
							}else{
								echo "OK";
							}
						}else{
							echo "ErrorActualizarGastoEmbarque";
						}
					}else{
						echo "OK1";
					}

				}else{
					echo "ErrorGastosEmbarque";
				}
			}else{
				//Registramos
				$gasto_embarque=embarqueModelo::gastoEmbarqueModelo($inse,  $tipo_gasto, 0, $embarque, $peso, $pago);

				if($gasto_embarque->rowCount()>=1){
					if($fg==1){
						//================================================
						$toneladas=embarqueModelo::obtenerToneladas($embarque);

						$regEmbasrque=[
							"embarque"=> $embarque,
							"pago"=> $pago,
							"peso"=> $peso,
							"toneladas"=>$toneladas
						];

						//Sumar el gasto y toneladas de fruta al embarque
						$gasto=embarqueModelo::agregarGasto($regEmbasrque);

						if($gasto->rowCount()>=1){
							$cantidad=$pago*$peso;

							$actCuenta=mainModel::ejecutar_consulta_simple("CALL update_pesos($embarque, $cantidad)");

							if($actCuenta->rowCount()>=1){
								echo "OK1";
							}else{
								echo "OK";
							}
						}else{
							echo "ErrorGastoToneladas";
						}
					}elseif($fg==2){
						//Actualizamos la cantidad total de gastos del embarque
						$sumaGasto=[
							"Id_Embarque"=>$embarque,
							"Cantidad"=>$pago
						];

						$sumaGastoEmb=embarqueModelo::sumarGastoEmbarque($sumaGasto);

						if($sumaGastoEmb->rowCount()>=1){
							$actCuenta=mainModel::ejecutar_consulta_simple("CALL update_pesos($embarque, $pago)");

							if($actCuenta->rowCount()>=1){
								echo "OK1";
							}else{
								echo "Error";
							}
						}else{
							echo "ErrorActualizarGastoEmbarque";
						}
					}else{
						echo "OK1";
					}
				}else{
					echo "ErrorGastosEmbarque";
				}
			}
		}

		public function addPeladorextra(){
			$idPelador=$_POST['idPelador'];
			$trabajo=$_POST['trabajo'];
			$concepto=strtoupper($_POST['concepto']);
			$pago=$_POST['pago'];
			$fecha=$_POST['fecha'];
			$idEmb=$_POST['embarque'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regPeladorExtra(1, $idPelador, '',  $trabajo, '$concepto', $pago, '$fecha', $idEmb, '')");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		//Actualizar trabajo extra pelador desde la lista de trabajo extra
		public function updatePeladorExtra(){

			$idBPelador=$_POST['idBP'];
			$trabajo=$_POST['trabajo'];
			$concepto=strtoupper($_POST['concepto']);
			$pago=$_POST['pago'];
			$idEmb=$_POST['embarque'];
			$idExtra=$_POST['idE'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regPeladorExtra(2, 0,'$idBPelador',  $trabajo, '$concepto', $pago, '', $idEmb, '$idExtra' )");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		//Eliminar trabajo extra pelador
		public function deletePeladorExtra(){
			$idPelador=$_POST['id'];
			$idBPelador=$_POST['idBP'];
			$pago=$_POST['pago'];
			$idEmb=$_POST['embarque'];
			$idExtra=$_POST['idE'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regPeladorExtra(3, $idPelador, $idBPelador,  0, '', $pago, '', $idEmb, $idExtra )");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function finPeladorExtra_controlador(){
			$idBPelador=$_POST['idBP'];
			$idExtra=$_POST['idE'];

			$sql=mainModel::ejecutar_consulta_simple("CALL regPeladorExtra(4, 0, $idBPelador,  0, '', 0, '', 0, $idExtra )");

			if($sql->rowCount()>=1){
				return "OK1null";
			}else{
				return $sql;
			}
		}

		public function listarPeladoresExtra_controlador(){
			$idEmb=$_POST['id'];

			$sql=embarqueModelo::listarPeladoresExtra_modelo($idEmb);
			
			return $sql;
		}

		public function listarBolserosTodos_controlador(){
			$id = $_POST['embarque'];
			$dia= $_POST['dia'];
			$sql='';

			switch ($dia) {
				case 0:
				$sql=mainModel::ejecutar_consulta_simple("SELECT id_bolsero as id, concat(bolseros.nombre,' ', bolseros.Ap_p) as nombre FROM `bolsas_bolsero` INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id WHERE id_embarque=$id AND diaUno>0 AND estra=0 UNION SELECT 
				CONCAT('P',bolsas_pelador.id_pelador) as  id, concat(peladores.nombre,' ', peladores.Ap_p) as nombre FROM bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$id AND bolsas_pelador.estado=2");
				break;
				case 1:
				$sql=mainModel::ejecutar_consulta_simple("SELECT id_bolsero as id, concat(bolseros.nombre,' ', bolseros.Ap_p) as nombre FROM `bolsas_bolsero` INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id WHERE id_embarque=$id AND diaDos>0 AND estra=0 UNION SELECT 
				CONCAT('P',bolsas_pelador.id_pelador) as  id, concat(peladores.nombre,' ', peladores.Ap_p) as nombre FROM bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$id AND bolsas_pelador.estado=2");
				break;
				case 2:
				$sql=mainModel::ejecutar_consulta_simple("SELECT id_bolsero as id, concat(bolseros.nombre,' ', bolseros.Ap_p) as nombre FROM `bolsas_bolsero` INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id WHERE id_embarque=$id AND diaTres>0 AND estra=0 UNION SELECT 
				CONCAT('P',bolsas_pelador.id_pelador) as  id, concat(peladores.nombre,' ', peladores.Ap_p) as nombre FROM bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$id AND bolsas_pelador.estado=2");
				break;
				case 3:
				$sql=mainModel::ejecutar_consulta_simple("SELECT id_bolsero as id, concat(bolseros.nombre,' ', bolseros.Ap_p) as nombre FROM `bolsas_bolsero` INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id WHERE id_embarque=$id AND diaCuatro>0 AND estra=0 UNION SELECT 
				CONCAT('P',bolsas_pelador.id_pelador) as  id, concat(peladores.nombre,' ', peladores.Ap_p) as nombre FROM bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$id AND bolsas_pelador.estado=2");
				break;
				case 4:
				$sql=mainModel::ejecutar_consulta_simple("SELECT id_bolsero as id, concat(bolseros.nombre,' ', bolseros.Ap_p) as nombre FROM `bolsas_bolsero` INNER JOIN bolseros on bolsas_bolsero.id_bolsero=bolseros.id WHERE id_embarque=$id AND diaCinco>0 AND estra=0 UNION SELECT 
				CONCAT('P',bolsas_pelador.id_pelador) as  id, concat(peladores.nombre,' ', peladores.Ap_p) as nombre FROM bolsas_pelador INNER JOIN peladores on bolsas_pelador.id_pelador=peladores.id WHERE bolsas_pelador.id_embarque=$id AND bolsas_pelador.estado=2");
				break;
			}

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function listarFrutaCapturada(){
			$id=$_POST['id'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT pf.id, id_fruta, round(pf.peso,2) peso, pf.fecha_compra, f.id_productores, round(f.pago,2) pago, concat(p.nombre,' ', p.Ap_p, ' ', p.Ap_m) as nombre FROM productor_fruta pf, fruta f, productores p WHERE pf.id_fruta=f.id AND p.id=f.id_productores AND f.id_embarque=$id AND pf.peso>0 ORDER BY cast(pf.id as int) DESC");

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function modificarFrutaCapturada(){
			$embarque=$_POST['embarque'];
			$fruta=$_POST['fruta'];
			$produc=$_POST['produc'];
			$peso=$_POST['peso'];
			$pesoNew=$_POST['pesoNew'];
			$pago=$_POST['pago'];
			$pagoNew=$_POST['pagoNew'];
			$cantidad=0;
			$pesoN=0;
			
			$cantidad=($pesoNew*$pagoNew)-($peso*$pago);

			$pesoN=$pesoNew-$peso;

			$sql=mainModel::ejecutar_consulta_simple("CALL modPesasCapturadas($fruta, $produc, $pesoN, $pagoNew, $embarque, $cantidad)");

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}
		}

		public function eliminarFrutaCapturada(){
			$embarque=$_POST['embarque'];
			$fruta=$_POST['fruta'];
			$produc=$_POST['produc'];
			$peso=$_POST['peso'];
			$pago=$_POST['pago'];
			$cantidad=0;

			$cantidad=(-1)*($peso*$pago);

			$sql=mainModel::ejecutar_consulta_simple("CALL modPesasCapturadas($fruta, $produc, ((-1)*($peso)), $pago, $embarque, $cantidad)");

			if($sql->rowCount()>=1){
				return "OK";
			}else{
				return $sql;
			}
		}


		public function obtenerRendimiento(){
			$id=$_POST['id'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT round( (cant_bolsas_embarque/toneladas),2) rendimiento FROM embarque WHERE id=$id");

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

		public function listaPeladoresControlador(){
			$id=$_POST['id'];

			$sql=mainModel::ejecutar_consulta_simple("SELECT peladores.id, peladores.nombre, peladores.Ap_p, peladores.Ap_m from peladores");

			return $sql->fetchAll(PDO::FETCH_ASSOC);
		}

	}