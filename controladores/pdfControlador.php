<?php 


if ($peticionAjax) {
    require_once "../core/mainModel.php";
    require_once "../vistas/assets/pdf/vendor/autoload.php";
} else {
    require_once "./core/mainModel.php";
    require_once "./vistas/assets/pdf/vendor/autoload.php";
}
	use Dompdf\Dompdf;
	class pdf_controlador extends mainModel {
    
    public function crear_pdf (){
        $id= $_POST['id'];
        $sql=mainModel::ejecutar_consulta_simple("SELECT id_embarque, fecha_compra, id_productores, peso_kg, pago, productor_fruta.peso as pesos, CONCAT(`nombre`,' ', `Ap_p`,' ',`Ap_m`) as nam FROM fruta INNER JOIN productor_fruta on fruta.id= productor_fruta.id_fruta INNER JOIN productores ON fruta.id_productores=productores.id where id_productores='$id'");
        if($sql->rowCount()>=1){
        	$row= $sql->fetch();
        	ob_start();
?>
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
				<!DOCTYPE html>
				<html lang="en">
				<head>
					<meta charset="UTF-8">
					<title>Factura</title>
				</head>
				<body>
					<div id="page_pdf">
						<table id="factura_head">
							<tr>
								<td >
									<div>
									</div>
								</td>
								<td class="info_empresa">
									<div>
										<span class="h2">PLATANERA TAB.</span>
										<p>Carretera Cunduacán-Villahermosa</p>
										<p>Teléfono: +(502) 2222-3333</p>
										<p>Email: info@abelosh.com</p>
									</div>
								</td>
								<td class="info_factura">
									<div class="round">
										<span class="h3">Factura</span>
										<p>Fecha:<?php echo $row['fecha_compra'];?></p>
										<p>Hora: 10:30am</p>
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
												<td><label>N° Embarque:</label><p><?php echo $row['id_embarque'];?></p></td>
												<td><label>Id Productor:</label> <p><?php echo $row['id_productores'];?></p></td>
											</tr>
											<tr>
												<td><label>Productor:</label> <p><?php echo $row['nam'];?></p></td>

											</tr>
										</table>
									</div>
								</td>

							</tr>
						</table>

						<table id="factura_detalle">
							<thead>
								<tr>
									<th width="50px"></th>
									<th class="textleft"></th>
									<th class="textright" width="150px"> </th>
									<th class="textright" width="150px"> Peso</th>
								</tr>
							</thead>
							<tbody id="detalle_productos">
								<?php 
								foreach ($row as $data){
									?>
									<tr>
										<td></td>
										<td></td>
										<td class="textright"></td>
										<td class="textright"><?php echo $data['pesos']; ?> </td>
									</tr>
									<?php
								}
								?>
							</tbody>
							<tfoot id="detalle_totales">
								<tr>
									<td colspan="3" class="textright"><span>TOTAL (Kg's)</span></td>
									<td class="textright"><span><?php echo $row['peso_kg'];?></span></td>
								</tr>
								<tr>
									<td colspan="3" class="textright"><span>Pre. Comp</span></td>
									<td class="textright"><span>516.67</span></td>
								</tr>
								<tr>
									<td colspan="3" class="textright"><span>TOTAL (MNX)</span></td>
									<td class="textright"><span><?php echo $row['pago']; ?></span></td>
								</tr>
							</tfoot>
						</table>
					</div>
				</body>
				</html>

<?php 

			$dompdf=new Dompdf();
			$dompdf->loadHtml(ob_get_clean());
			$dompdf->setPaper('A4', 'landscape');
			$dompdf->render();
			$dompdf->stream();

		}else{
			return "error";
		}
	}
}
?>
    
