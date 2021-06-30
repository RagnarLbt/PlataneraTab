<?php 
	
	$opc=$_POST['opc'];
	$id=$_POST['idEmbarque'];
	$company=$_POST['company'];
	$mensaje='';

	$mysqli= new mysqli('localhost', 'root', '', 'platanera');
	ob_start();

	ini_set('date.timezone','America/Mexico_City'); 
	$hora= date("h:i:s A");
	$fecha = date("d-m-Y");

if($opc==1){
	$mensaje="Pago del Embarque $id a Productores";
	$query="SELECT concat(productores.nombre, ' ', productores.Ap_p, ' ', productores.Ap_m) nombre, productores.no_cuenta, fruta.id, fruta.id_productores, fruta.pago, fruta.peso_kg, CAST((fruta.pago*fruta.peso_kg) as decimal(10,2)) cantidad FROM fruta, productores WHERE fruta.id_productores=productores.id AND fruta.id_embarque=$id ORDER BY id_productores ASC";
	$result=$mysqli->query($query);
	$r=mysqli_fetch_array($result);

}elseif ($opc==2) {
	$mensaje="Pago del Embarque $id a Trabajadores";
	$query="SELECT bolseros.id, concat(bolseros.nombre,' ', bolseros.Ap_p,' ', bolseros.Ap_m) nombre, bolseros.no_cuenta, bolsas_bolsero.pago_bol pago FROM `bolsas_bolsero`, bolseros WHERE bolseros.id=bolsas_bolsero.id_bolsero AND bolsas_bolsero.id_embarque=$id GROUP BY nombre";
	$extras="SELECT CONCAT(nombre,' ',apellidos)";
	$query_1="SELECT peladores.id, concat(peladores.nombre,' ', peladores.Ap_p,' ', peladores.Ap_m) nombre, peladores.no_cuenta, sum(bolsas_pelador.cantidad_bolsas_pe*bolsas_pelador.pago_pe) pago FROM `bolsas_pelador`, peladores WHERE peladores.id=bolsas_pelador.id_pelador AND bolsas_pelador.id_embarque=$id GROUP BY nombre";
	$query_2="SELECT planilla_toston.id, concat(planilla_toston.nombre,' ', planilla_toston.Ap_p,' ', planilla_toston.Ap_m) nombre, planilla_toston.no_cuenta, sum(bolsas_toston.pago) pago FROM `bolsas_toston`, planilla_toston WHERE planilla_toston.id=bolsas_toston.id_planilla AND bolsas_toston.id_embarque=$id GROUP BY nombre";
	$result=$mysqli->query($query);
	$result_1=$mysqli->query($query_1);
	$result_2=$mysqli->query($query_2);
	$r=mysqli_fetch_array($result);

}elseif ($opc==3) {
	$mensaje="Cuenta de Embarque $id";
	$queryDolares="select dolares.id, dolares.concepto, dolares.ingreso, dolares.egreso, dolares.saldo from dolares
    INNER JOIN cuenta_dolares ON dolares.id_cuentaD=cuenta_dolares.id
    where cuenta_dolares.id_emb=$id";
    $queryD="SELECT cuenta_dolares.total_ingreso, cuenta_dolares.total_egreso, cuenta_dolares.total_saldo from cuenta_dolares WHERE cuenta_dolares.id_emb=$id";
	$queryPesos="SELECT pesos.id, pesos.concepto, pesos.ingreso, pesos.egreso, pesos.saldo from pesos
    INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id
    where cuenta_pesos.id_emb=$id";
    $queryP="select cuenta_pesos.total_ingreso, cuenta_pesos.total_egreso, cuenta_pesos.total_saldo from cuenta_pesos where cuenta_pesos.id_emb=$id";
    $queryResumen="SELECT embarque.total_gastos as gasto ,ROUND(SUM(dolares.taza_cambio)/ COUNT(dolares.taza_cambio),2) as taza,ROUND(embarque.total_gastos/(SUM(dolares.taza_cambio)/ COUNT(dolares.taza_cambio)),2) as gastoD, embarque.cant_bolsas_embarque as bolsas,ROUND(embarque.total_gastos/embarque.cant_bolsas_embarque, 2) as costoP,ROUND(embarque.total_gastos/(SUM(dolares.taza_cambio)/ (COUNT(dolares.taza_cambio))/embarque.cant_bolsas_embarque),2) as costoD from cuenta_dolares
    INNER join dolares on cuenta_dolares.id=dolares.id_cuentaD
    INNER JOIN embarque on embarque.id=cuenta_dolares.id_emb
    where cuenta_dolares.id_emb=$id";
    $resumen=$mysqli->query($queryResumen);
    $dolares=$mysqli->query($queryDolares);
    $dolar=$mysqli->query($queryD);
    $pesos=$mysqli->query($queryPesos);
    $peso=$mysqli->query($queryP);
    $r=mysqli_fetch_array($dolar);
    $r2=mysqli_fetch_array($peso);
    $r3=mysqli_fetch_array($resumen);
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Consultado <?php echo "Productor ".$_POST['idProductor']; ?></title>
	<link rel="stylesheet" href="../css/bootstrap.min.css">
	<style>
		*{
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		p, label, span, table{
			font-family: sans-serif;
			font-size: 9pt;
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
			padding: 0 15px;
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
						<span class="h3">Factura</span>
						<p>Fecha: <?php echo $fecha; ?></p>
						<p>Hora: <?php  echo $hora; ?></p>
					</div>
				</td>
			</tr>
		</table>

<?php if($opc==1){ ?>

		<table id="factura_detalle">
			<thead>
				<tr>
					<th class="text-center">Id</th>
					<th class="text-center">Nombre</th>
					<th class="text-center">No. Cuenta</th>
					<th class="text-center" width="150px">Cantidad</th>
				</tr>
			</thead>
			<tbody id="detalle_productos">
				
				<?php foreach($result as $fila){?>
					<tr>
						<td class="text-left"><?php echo $fila['id_productores']; ?></td>
						<td class="text-left"><?php echo $fila['nombre']; ?></td>
						<td class="text-left"><?php echo $fila['no_cuenta']; ?></td>
						<td class="text-right"><?php echo "$ ".$fila['cantidad']; ?></td>
					</tr>
					<?php
				}
				?>
				
			</tbody>
			
		</table>

<?php }elseif ($opc==2) {?>
		
		<h5 class="text-center">Bolsero</h5>
		<table id="factura_detalle">
			<thead>
				<tr>
					<th class="text-center">Id</th>
					<th class="text-center">Nombre</th>
					<th class="text-center">No. Cuenta</th>
					<th class="text-center" width="150px">Cantidad</th>
				</tr>
			</thead>
			<tbody id="detalle_productos">
				
				<?php foreach($result as $fila){?>
					<tr>
						<td class="text-left"><?php echo $fila['id']; ?></td>
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
		<h5 class="text-center">Peladores</h5>
		<table id="factura_detalle">
			<thead>
				<tr>
					<th class="text-center">Id</th>
					<th class="text-center">Nombre</th>
					<th class="text-center">No. Cuenta</th>
					<th class="text-center" width="150px">Cantidad</th>
				</tr>
			</thead>
			<tbody id="detalle_productos">
				
				<?php foreach($result_1 as $fila){?>
					<tr>
						<td class="text-left"><?php echo $fila['id']; ?></td>
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
		<h5 class="text-center">Planilla Toston</h5>
		<table id="factura_detalle">
			<thead>
				<tr>
					<th class="text-center">Id</th>
					<th class="text-center">Nombre</th>
					<th class="text-center">No. Cuenta</th>
					<th class="text-center" width="150px">Cantidad</th>
				</tr>
			</thead>
			<tbody id="detalle_productos">
				
				<?php foreach($result_2 as $fila){?>
					<tr>
						<td class="text-left"><?php echo $fila['id']; ?></td>
						<td class="text-left"><?php echo $fila['nombre']; ?></td>
						<td class="text-left"><?php echo $fila['no_cuenta']; ?></td>
						<td class="text-right"><?php echo $fila['pago']; ?></td>
					</tr>
					<?php
				}
				?>
				
			</tbody>
			
		</table>

<?php } elseif($opc==3){?>

	<h5 class="text-center">Cuenta en Dolares</h5>
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
					<td class="text-center text-uppercase" width="150px"><?php echo $fila['concepto']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['ingreso']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['egreso']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['saldo']; ?></td>
				</tr>
				<?php
			}
			?>
			<tr>
				<td class="text-center font-weight-bold text-uppercase">Total</td>
				<td class="text-center" width="150px"><?php echo $r['total_ingreso']; ?></td>
				<td class="text-center" width="150px"><?php echo $r['total_egreso']; ?></td>
				<td class="text-center" width="150px"><?php echo "$ ".$r['total_saldo']; ?></td>
			</tr>
		</tbody>

	</table> <br>

	<h5 class="text-center">Cuenta en Pesos</h5>
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
					<td class="text-center text-uppercase" width="150px"><?php echo $fila['concepto']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['ingreso']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['egreso']; ?></td>
					<td class="text-center" width="150px"><?php echo $fila['saldo']; ?></td>
				</tr>
				<?php
			}

			?>
			<tr>
				<td class="text-center font-weight-bold text-uppercase">Total</td>
				<td class="text-center" width="150px"><?php echo $r2['total_ingreso']; ?></td>
				<td class="text-center" width="150px"><?php echo $r2['total_egreso']; ?></td>
				<td class="text-center" width="150px"><?php echo "$ ".$r2['total_saldo']; ?></td>
			</tr>
		</tbody>

	</table> <br>

	<h5 class="text-center">Resumen</h5>
	<table id="factura_detalle" class="table-borderless">

		<tbody id="detalle_productos">
			<tbody >
				<tr>
					<td class="text-center" width="500px">GASTO  TOTAL  EMBARQUE</td>
					<td class="text-center" width="500px"><?php echo $r3['gasto'];?></td>
				</tr>
				<tr >
					<td class="text-center" width="500px">GASTO  TOTAL  EMBARQUE   DÓLAR</td>
					<td class="text-center" width="500px"><?php echo $r3['gastoD'];?></td>

				</tr>
				<tr >
					<td class="text-center" width="500px">TAZA    DE     CAMBIO</td>
					<td class="text-center" width="500px"><?php echo $r3['taza'];?></td>

				</tr>
				<tr >
					<td class="text-center" width="500px">CANTIDAD   DE   BOLSAS</td>
					<td class="text-center" width="500px"><?php echo $r3['bolsas'];?></td>

				</tr>
				<tr >
					<td class="text-center" width="500px">COSTO    PESOS</td>
					<td class="text-center" width="500px"><?php echo $r3['costoP'];?></td>

				</tr>
				<tr >
					<td class="text-center" width="500px">COSTO    DÓLAR</td>
					<td class="text-center" width="500px"><?php echo $r3['costoD'];?></td>

				</tr>
			</tbody>
			
		</tbody>

	</table> 

<?php }?>

	</div>
</body>
</html>
<?php 
require_once "../assets/pdf/vendor/autoload.php";
use Dompdf\Dompdf;

$dompdf=new Dompdf();
$dompdf->loadHtml(ob_get_clean());
$dompdf->setPaper('A4', 'landscape');
$dompdf->render();
//$dompdf->stream();
$pdf = $dompdf->output();
$filename = 'PagoEmbarque'.$id.'.pdf';
$dompdf->stream($filename, array("Attachment" => 0));
?>