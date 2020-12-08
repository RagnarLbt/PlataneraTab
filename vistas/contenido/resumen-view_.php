<?php 
	session_start();

	include "../../core/mainModel.php";
	$mm= new mainModel();
	ob_start()

	$usuario='Alejandra';
	$idEmbarque=50; 
	$fecha= '2020/08/12'; 
	$idProd=1;
	$query="SELECT ";

	$result=$mysqli->query($query);
	$r=mysqli_fetch_array($result);

	ini_set('date.timezone','America/Mexico_City'); 
	$hora= date("H:i:s");
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Resumen del Día</title>
	<link rel="stylesheet" href="../css/bootstrap.min.css">
	<link rel="icon" href="../assets/icons/bananas.png" type="image/png"/>
	<style>
		*{
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		p, label, span, table{
			font-family: 'BrixSansRegular';
			font-size: 9pt;
		}
		.h2{
			font-family: 'BrixSansBlack';
			font-size: 16pt;
		}
		.h3{
			font-family: 'BrixSansBlack';
			font-size: 15pt;
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
		.info_cliente  tr:nth-child(even){
			width: 70%;
            background: #ededed;
            
           
		}
		.datos_cliente{
			width: 100%;
          
		}
		.datos_cliente tr td{
			width: 100%;
            font-size: medium;
           
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
				<td >
					<div>
					</div>
				</td>
				<td class="info_empresa" style="font-size: large;">
					<div>
						<span class="h2">PLATANERA TAB.</span>
						<p>Carretera Cunduacán-Villahermosa</p>
						<p>Teléfono: +(502) 2222-3333</p>
						<p>Email: info@abelosh.com</p>
					</div>
				</td>
				<td class="info_factura">
					<div class="round">
						<span class="h3">Datos</span>
						<p>Fecha: <?php echo $fecha ?></p>

						<p>Hora: <?php  echo $hora?></p>
						<p>Id de Embarque: <?php  echo $idEmbarque?> </p>
						<p>Usuario: <?php echo $usuario ?></p>
					</div>
				</td>
			</tr>
		</table>
		<table id="factura_cliente">
			<tr>
				<td class="info_cliente">
					<div class="round">
						<span class="h3">Resúmen del día</span>
						<table class="datos_cliente" id="detalle_productos">
							<tr>
								<?php //echo $r['fecha_compra']?> 
								<td >Cantidad de bolsas</td>
								<td >{{lista.bolsas}}</td>
							</tr>
							<tr>
								<td >Toneladas de fruta</td>
								<td>{{lista.peso}}</td>
							</tr>
							<tr>
								<td >Pago productres</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
							<tr>
								<td >Pago planilla</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
							<tr>
								<td >Pago peladores</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
							<tr>
								<td >Pago bolseros</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
							<tr>
								<td >Total gastos hoy</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
							<tr>
								<td >Gastos hasta el día</td>
								<td >$ {{lista.gasto}}</td>
							</tr>
						</table>
					</div>
				</td>

			</tr>
		</table>
	</div>
</body>
</html>
<?php 
require_once "pdf/vendor/autoload.php";
use Dompdf\Dompdf;

$dompdf=new Dompdf();
$dompdf->loadHtml(ob_get_clean());
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();
$pdf = $dompdf->output();
$filename = 'Resumen.pdf';
$dompdf->stream($filename, array("Attachment" => 0));
?>