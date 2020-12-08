<?php 
	date_default_timezone_set ("America/Mexico_City");
	ob_start();
	$pdf=true;
	include "../../core/mainModel.php";
	$mm= new mainModel();
	$hora= date("H:i:s");
	$fechaCons = date("d-m-Y");

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Reporte</title>
	<link rel="stylesheet" href="../css/bootstrap.min.css">
	<link rel="icon" href="../assets/icons/bananas.png" type="image/png"/>	
	<style>
		*{
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		p, label, span, table{
			font-family: sans-serif;
			font-size: 8pt;
		}
		.h2{
			font-family: sans-serif;
			font-size: 16pt;
		}
		.h3{
			font-family: sans-serif;
			font-size: 12pt;
			display: block;
			background: #0a4661;
			color: #FFF;
			text-align: center;
			padding: 3px;
			margin-bottom: 5px;
		}
		#page_pdf{
			width: 95%;
			margin: 15px auto 10px auto;
		}

		#factura_head, #factura_cliente, #factura_detalle{
			width: 100%;
			margin-bottom: 10px;
		}
		.logo_factura{
			width: 25%;
		}
		.info_empresa{
			width: 50%;
			text-align: center;
		}
		.info_factura{
			width: 25%;
		}
		.info_cliente{
			width: 100%;
		}
		.datos_cliente{
			width: 100%;
		}
		.datos_cliente tr td{
			width: 50%;
		}
		.datos_cliente{
			padding: 10px 10px 0 10px;
		}
		.datos_cliente label{
			width: 75px;
			display: inline-block;
		}
		.datos_cliente p{
			display: inline-block;
		}

		.textright{
			text-align: right;
		}
		.textleft{
			text-align: left;
		}
		.textcenter{
			text-align: center;
		}
		.round{
			border-radius: 10px;
			border: 1px solid #0a4661;
			overflow: hidden;
			padding-bottom: 15px;
		}
		.round p{
			padding: 0 5px;
		}

		#factura_detalle{
			border-collapse: collapse;
		}
		#factura_detalle thead th{
			background: #058167;
			color: #FFF;
			padding: 5px;
		}
		#detalle_productos tr:nth-child(even) {
			background: #ededed;
		}
		#detalle_totales span{
			font-family: 'BrixSansBlack';
		}
		.nota{
			font-size: 8pt;
		}
		.label_gracias{
			font-family: verdana;
			font-weight: bold;
			font-style: italic;
			text-align: center;
			margin-top: 20px;
		}
		.anulada{
			position: absolute;
			left: 50%;
			top: 50%;
			transform: translateX(-50%) translateY(-50%);
		}
	</style>
</head>
<body>

	<?php 
 //PDF Para la factura del productor
		if(isset($_POST['idProductor']) && isset($_POST['fechaAct']) && isset($_POST['idEmbarque']) && isset($_POST['user']) ){


			$usuario=$_POST['user'];
			$idEmbarque=$_POST['idEmbarque']; 
			$fecha= $_POST['fechaAct'];
			$idProd= $_POST['idProductor'];
			
			$fileName="E".$idEmbarque." - Prod#".$idProd." - ".$fecha;

			$sql=$mm->consulta("SELECT fruta.id_embarque, fruta.id_productores,  fruta.saldo_abono,  fruta.peso_kg, fruta.pago, CONCAT(`nombre`,' ', `Ap_p`,' ',`Ap_m`) as nombre from fruta INNER JOIN embarque on fruta.id_embarque=embarque.id INNER JOIN productores on fruta.id_productores=productores.id WHERE fruta.id_productores=$idProd and fruta.id_embarque=$idEmbarque");
			$datos=$sql->fetch();

			$sqlData=$mm->consulta("SELECT productor_fruta.id, peso, CONCAT(productor_fruta.fecha_compra,' - ', productor_fruta.hora_compra) hora_compra FROM productor_fruta, fruta WHERE fruta.id=productor_fruta.id_fruta AND productor_fruta.peso>0 AND fruta.id_productores=$idProd AND fruta.id_embarque=$idEmbarque");
			$row=$sqlData->fetchAll();
			//print_r($datos);
			//print_r($row);

	?>
	
	<div class="container-fluid">
		<div id="page_pdf">
			<table id="factura_head">
				<tr>
					<td>
						<div>
						</div>
					</td>
					<td class="info_empresa">
						<div>
							<span class="h2">AGROEXPORTACIONES CHONTALPA</span>
							<p>Carretera Cunduacán-Villahermosa</p>
							<!--p>Teléfono: +(52) Número de la empresa</p>
							<p>Email: info@abelosh.com</p-->
						</div>
					</td>
					<td class="info_factura">
						<div class="round">
							<span class="h3">Factura</span>
							<p>Fecha: <?php echo $fecha ?></p>
							<p>Hora: <?php  echo $hora ?></p>
						</div>
					</td>
				</tr>
			</table>
			<table id="factura_cliente">
				<tr>
					<td class="info_cliente">
						<div class="round">
							<span class="h3">Info</span>
							<table class="datos_cliente">
								<tr>
									<td><label>N° Embar:</label><p> <?php echo $idEmbarque ?></p></td>
									<td><label>N° Productor:</label><p> <?php echo $idProd ?></p></td>
								</tr>
								<tr>
									<td><label>Productor:</label> <p> <?php echo $datos['nombre'] ?></p></td>
									<td><label>Atendio:</label> <p class="text-uppercase"> <?php echo $usuario ?></p></td>
								</tr>
							</table>
						</div>
					</td>

				</tr>
			</table>

			<table id="factura_detalle">
				<thead>
					<tr>
						<th class="text-center" width="50px">Pesa No.</th>
						<th class="text-center" width="150px">Hora</th>
						<th class="text-center" width="150px">Pesos (Kg's)</th>
					</tr>
				</thead>
				<tbody id="detalle_productos">
					<?php foreach($row as $f){?>
						<tr>
							<td class="text-right" width="50px"><?php echo $f['id']."  " ?></td>
							<td class="text-center" width="150px"><?php echo $f['hora_compra']."  " ?></td>
							<td class="text-right" width="150px"><?php echo $f['peso']."  " ?></td>
						</tr>
					<?php
						}
					?>
					<tr>
						<td></td>
						<td></td>
					</tr>
				</tbody>
				<tfoot id="detalle_totales">
					<tr>
						<td></td>
						<td class="textleft"><span>TOTAL (Kg's)</span></td>
						<td class="textright"><span class="font-weight-bolder"><?php echo $datos['peso_kg']."  "?></span></td>
					</tr>
					<!--tr>
						<td></td>
						<td class="textleft"><span>Pre. Comp</span></td>
						<td class="textright"><span class="font-weight-bolder"><?php echo $datos['pago']."  "?></span></td>
					</tr>
					<tr>
						<td></td>
						<td class="textleft"><span>TOTAL (MNX)</span></td>
						<td class="textright"><span class="font-weight-bolder"><?php echo $datos['saldo_abono']."  "?></span></td>
					</tr-->
				</tfoot>
			</table>
		</div>
	</div>

	<?php
 //Fin PDF factura del productor

 //PDF Para Pagos de Embarque
		}elseif(isset($_POST['opc']) && isset($_POST['idEmbarque']) ){
			$opc=$_POST['opc'];
			$id=$_POST['idEmbarque'];
			$company=$_POST['company'];
			$mensaje='';
			$fileName="E".$id."-".$fechaCons;
			$mensaje="<code>Embarque $id</code>";
	?>

			<div id="page_pdf">

				<table id="factura_head">
					<tr>
						<td>
							<div>
							</div>
						</td>
						<td class="info_empresa">
							<div>
								<span class="h2"><?php echo $company; ?></span>
								<p>Carretera Cunduacán-Villahermosa</p>
								<p><?php echo $mensaje; ?></p>
							</div>
						</td>
						<td class="info_factura">
							<div class="round">
								<span class="h3">Impresión</span>
								<p>Fecha: <?php echo $fechaCons; ?></p>
								<p>Hora: <?php  echo $hora; ?></p>
							</div>
						</td>
					</tr>
				</table>
	<?php

			if($opc==1){
				$mensaje="Pago del Embarque $id a Productores";
				$query=$mm->consulta("SELECT concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, productores.no_cuenta, fruta.id, fruta.id_productores, fruta.pago, fruta.peso_kg, CAST((fruta.pago*fruta.peso_kg) as decimal(10,2)) cantidad FROM fruta, productores WHERE fruta.id_productores=productores.id AND fruta.id_embarque=$id ORDER BY id_productores ASC");
				$result=$query->fetchAll();	
	?>
				<table id="factura_detalle">
					<thead>
						<tr>
							<!--th class="text-center">Id</th-->
							<th class="text-center">Nombre</th>
							<th class="text-center">No. Cuenta</th>
							<th class="text-center" width="150px">Cantidad</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($result as $fila){?>
							<tr>
								<!--td class="text-left"><?php echo $fila['id_productores']; ?></td.-->
								<td class="text-left"><?php echo $fila['nombre']; ?></td>
								<td class="text-left"><?php echo $fila['no_cuenta']; ?></td>
								<td class="text-right"><?php echo "$ ".$fila['cantidad']; ?></td>
							</tr>
							<?php
						}
						?>
					</tbody>
				</table>
	<?php

			}elseif($opc==2){

				$query=$mm->consulta("SELECT bolseros.id, concat(bolseros.nombre,' ', bolseros.Ap_p,' ', bolseros.Ap_m) nombre, bolseros.no_cuenta, bolsas_bolsero.pago_bol pago FROM `bolsas_bolsero`, bolseros WHERE bolseros.id=bolsas_bolsero.id_bolsero AND bolsas_bolsero.id_embarque=$id GROUP BY nombre");
				$result=$query->fetchAll();

				$queryUno=$mm->consulta("SELECT CONCAT(nombre,' ', apellidos) as nombre, cuenta, pago FROM `bolsero_extra` WHERE id_embarque=$id");
				$resultUno=$queryUno->fetchAll();

				$queryDos=$mm->consulta("SELECT peladores.id, concat(peladores.nombre,' ', peladores.Ap_p,' ', peladores.Ap_m) nombre, peladores.no_cuenta, SUM(bolsas_pelador.pago_pe) pago FROM `bolsas_pelador`, peladores WHERE peladores.id=bolsas_pelador.id_pelador AND bolsas_pelador.id_embarque=$id GROUP BY bolsas_pelador.id_pelador");
				$resultDos=$queryDos->fetchAll();

				$queryTres=$mm->consulta("SELECT planilla_toston.id, concat(planilla_toston.nombre,' ', planilla_toston.Ap_p,' ', planilla_toston.Ap_m) nombre, planilla_toston.no_cuenta, sum(bolsas_toston.pago) pago FROM `bolsas_toston`, planilla_toston WHERE planilla_toston.id=bolsas_toston.id_planilla AND bolsas_toston.id_embarque=$id GROUP BY nombre");
				$resultTres=$queryTres->fetchAll();

	?>
				<p class="text-center">Bolsero</p>
				<table id="factura_detalle">
					<thead>
						<tr>
							<!--th class="text-center">Id</th-->
							<th class="text-center">Nombre</th>
							<th class="text-center">No. Cuenta</th>
							<th class="text-center" width="150px">Cantidad</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($result as $fila){?>
							<tr>
								<!--td class="text-left"><?php echo $fila['id']; ?></td-->
								<td class="text-left"><?php echo $fila['nombre']; ?></td>
								<td class="text-left"><?php echo $fila['no_cuenta']; ?></td>
								<td class="text-right"><?php echo "$ ".$fila['pago']; ?></td>
							</tr>
						<?php
						}
						?>

					</tbody>

				</table>
				<p class="text-center alert-success">Extra</p>
				<table id="factura_detalle">
					<thead>
						<tr>
							<th class="text-center">Nombre</th>
							<th class="text-center">No. Cuenta</th>
							<th class="text-center" width="150px">Cantidad</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($resultUno as $fila){?>
							<tr>
								<td class="text-left"><?php echo $fila['nombre']; ?></td>
								<td class="text-left"><?php echo $fila['cuenta']; ?></td>
								<td class="text-right"><?php echo "$ ".$fila['pago']; ?></td>
							</tr>
						<?php
						}
						?>

					</tbody>

				</table>

				<br>
				<p class="text-center">Peladores</p>
				<table id="factura_detalle">
					<thead>
						<tr>
							<!--th class="text-center">Id</th-->
							<th class="text-center">Nombre</th>
							<th class="text-center">No. Cuenta</th>
							<th class="text-center" width="150px">Cantidad</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($resultDos as $fila){?>
							<tr>
								<!--td class="text-left"><?php echo $fila['id']; ?></td-->
								<td class="text-left"><?php echo $fila['nombre']; ?></td>
								<td class="text-left"><?php echo $fila['no_cuenta']; ?></td>
								<td class="text-right"><?php echo "$ ".$fila['pago']; ?></td>
							</tr>
						<?php
							}
						?>

					</tbody>

				</table>

				<br>
				<p class="text-center">Planilla Toston</p>
				<table id="factura_detalle">
					<thead>
						<tr>
							<!--th class="text-center">Id</th-->
							<th class="text-center">Nombre</th>
							<th class="text-center">No. Cuenta</th>
							<th class="text-center" width="150px">Cantidad</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($resultTres as $fila){?>
							<tr>
								<!--td class="text-left"> <?php echo $fila['id']; ?></td-->
								<td class="text-left"> <?php echo $fila['nombre']; ?></td>
								<td class="text-left"> <?php echo $fila['no_cuenta']; ?></td>
								<td class="text-right">$ <?php echo $fila['pago']; ?></td>
							</tr>
							<?php
						}
						?>

					</tbody>

				</table>
	<?php
			}elseif($opc==3){
				$query=$mm->consulta("SELECT dolares.* FROM `cuenta_dolares`, dolares WHERE dolares.id_cuentaD=cuenta_dolares.id AND cuenta_dolares.id_emb=$id AND mostrar=1");
				$dolares=$query->fetchAll();

				$queryUno=$mm->consulta("SELECT pesos.id, pesos.concepto, pesos.ingreso, pesos.egreso, pesos.saldo from pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id where cuenta_pesos.id_emb=$id AND mostrar=1");
				$pesos=$queryUno->fetchAll();

				$queryDos=$mm->consulta("SELECT bolsas.id, bolsas.concepto, bolsas.ingreso, bolsas.egreso, bolsas.saldo from bolsas INNER JOIN cuenta_bolsas on bolsas.id_cuenta=cuenta_bolsas.id where cuenta_bolsas.idemb=$id AND mostrar=1");
				$bolsas=$queryDos->fetchAll();

				$queryTres=$mm->consulta("SELECT embarque.total_gastos as gasto, CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$id) as decimal(10,2)) as taza, cast(embarque.total_gastos/CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$id) as decimal(10,4)) as decimal(10,2)) as gastoD, (embarque.cant_bolsas_embarque) as bolsas, cast(embarque.total_gastos/embarque.cant_bolsas_embarque as decimal(10,2)) as costoP, cast( ( (embarque.total_gastos)/ ( CAST(SUM(dolares.taza_cambio)/ (SELECT COUNT(dolares.taza_cambio) FROM dolares, cuenta_dolares WHERE dolares.taza_cambio!=0 AND cuenta_dolares.id=dolares.id_cuentaD AND cuenta_dolares.id_emb=$id) as decimal(10,4)) ) ) / (embarque.cant_bolsas_embarque) as decimal(10,2)) as costoD from cuenta_dolares INNER join dolares on cuenta_dolares.id=dolares.id_cuentaD INNER JOIN embarque on embarque.id=cuenta_dolares.id_emb where cuenta_dolares.id_emb=$id");
				$resumen=$queryTres->fetch();

				$queryTotal=$mm->consulta("SELECT cd.total_ingreso, cd.total_egreso, cd.total_saldo, cp.total_ingreso, cp.total_egreso, cp.total_saldo ,cb.ingreso, cb.egreso, cb.saldo FROM cuenta_bolsas cb, cuenta_pesos cp, cuenta_dolares cd WHERE cb.id=cd.id AND cd.id=cp.id AND cp.id_emb=$id");
				$rTotales=$queryTotal->fetch();
	?>
				<p class="text-center">Cuenta en Dolares</p>
				<table id="factura_detalle">
					<thead>
						<tr>
							<th class="text-center">Concepto</th>
							<th class="text-center">Ingreso</th>
							<th class="text-center">Egreso</th>
							<th class="text-center">Saldo</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($dolares as $fila){?>
							<tr>
								<td class="text-left text-uppercase" width="150px"><?php echo $fila['concepto']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['ingreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['egreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['saldo']; ?></td>
							</tr>
							<?php
						}
						?>
						<tr>
							<td class="text-center font-weight-bold text-uppercase">Total</td>
							<td class="text-right" width="150px"><?php echo $rTotales[0]; ?></td>
							<td class="text-right" width="150px"><?php echo $rTotales[1]; ?></td>
							<td class="text-right" width="150px"><?php echo "$ ".$rTotales[2]; ?></td>
						</tr>
					</tbody>

				</table><br>

				<p class="text-center">Cuenta en Pesos</p>
				<!-- Pesos -->
				<table id="factura_detalle">
					<thead>
						<tr>
							<th class="text-center">Concepto</th>
							<th class="text-center">Ingreso</th>
							<th class="text-center">Egreso</th>
							<th class="text-center">Saldo</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($pesos as $fila){?>
							<tr>
								<td class="text-left text-uppercase" width="150px"><?php echo $fila['concepto']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['ingreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['egreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['saldo']; ?></td>
							</tr>
							<?php
						}

						?>
						<tr>
							<td class="text-center font-weight-bold text-uppercase">Total</td>
							<td class="text-right" width="150px"><?php echo $rTotales[3]; ?></td>
							<td class="text-right" width="150px"><?php echo $rTotales[4]; ?></td>
							<td class="text-right" width="150px"><?php echo "$ ".$rTotales[5]; ?></td>
						</tr>
					</tbody>
				</table><br>

				<p class="text-center">Cuenta en Bolsas</p>
				<!-- Bolsas -->
				<table id="factura_detalle">
					<thead>
						<tr>
							<th class="text-center">Concepto</th>
							<th class="text-center">Ingreso</th>
							<th class="text-center">Egreso</th>
							<th class="text-center">Saldo</th>
						</tr>
					</thead>
					<tbody id="detalle_productos">

						<?php foreach($bolsas as $fila){?>
							<tr>
								<td class="text-left text-uppercase" width="150px"><?php echo $fila['concepto']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['ingreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['egreso']; ?></td>
								<td class="text-right" width="150px"><?php echo $fila['saldo']; ?></td>
							</tr>
							<?php
						}

						?>
						<tr>
							<td class="text-center font-weight-bold text-uppercase">Total</td>
							<td class="text-right" width="150px"><?php echo $rTotales[6]; ?></td>
							<td class="text-right" width="150px"><?php echo $rTotales[7]; ?></td>
							<td class="text-right" width="150px"><?php echo "$ ".$rTotales[8]; ?></td>
						</tr>
					</tbody>
				</table><br>

				<p class="text-center">Resumen</p>
				<table id="factura_detalle" class="table-bordered">
					<tbody id="detalle_productos">
						<tbody>
							<tr class="alert-secondary">
								<td class="text-left" width="250px">GASTO TOTAL EMBARQUE</td>
								<td class="text-right" width="250px"><?php echo $resumen['gasto']." ";?></td>
							</tr>
							<tr >
								<td class="text-left" width="250px">GASTO TOTAL EMBARQUE DÓLAR</td>
								<td class="text-right" width="250px"><?php echo $resumen['gastoD']." ";?></td>
							</tr>
							<tr class="alert-secondary">
								<td class="text-left" width="250px">TAZA DE CAMBIO</td>
								<td class="text-right" width="250px"><?php echo $resumen['taza']." ";?></td>
							</tr>
							<tr>
								<td class="text-left" width="250px">CANTIDAD DE BOLSAS</td>
								<td class="text-right" width="250px"><?php echo $resumen['bolsas']." ";?></td>
							</tr>
							<tr class="alert-secondary">
								<td class="text-left" width="250px">COSTO PESOS</td>
								<td class="text-right" width="250px"><?php echo $resumen['costoP']." ";?></td>
							</tr>
							<tr >
								<td class="text-left" width="250px">COSTO DÓLAR</td>
								<td class="text-right" width="250px"><?php echo $resumen['costoD']." ";?></td>
							</tr>
						</tbody>
						
					</tbody>
				</table> 
	<?php
			}
	?>
		</div>
	<?php
		}
	?>
</body>
</html>
<?php 
	require_once "../assets/pdf/vendor/autoload.php";
	use Dompdf\Dompdf;

	$dompdf=new Dompdf();
	$dompdf->loadHtml(ob_get_clean());
	$dompdf->setPaper('A4', 'portrait');
	$dompdf->render();
	$pdf = $dompdf->output();
	$dompdf->stream($fileName, array("Attachment" => 0));
?>