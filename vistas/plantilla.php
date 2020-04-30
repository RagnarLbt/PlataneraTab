<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Home</title>
	<!--link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/normalize.css"-->
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/material-design-iconic-font.min.css">
	<!--link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/material.min.css">
	<link rel="stylesheet" href="<?php echo SERBERURL; ?>vistas/dt/datatables.min.css"-->
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/jquery.mCustomScrollbar.css">
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/bootstrap.min.css">
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/sweetalert2.min.css">
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/main.css">
</head>
<body>


	<?php
		$peticionAjax=false;

		require_once "./controladores/vistasControlador.php";
		$vt= new vistasControlador();
		$vistasR=$vt->obtener_vistas_controlador();
		
		if($vistasR == "./vistas/contenido/login-view.php" || $vistasR == "login"){
			//include "./vistas/modulos/scripts.php";
			require_once "./vistas/contenido/login-view.php";
		}else{
			session_start();
			require_once "./vistas/modulos/lateralMenu.php";
	?>

				<section id="container" class="">
					
				    <!-- Content page -->
				    <?php require_once $vistasR; ?>

				</section>
			</section>

	<?php }

		require_once "./vistas/modulos/scripts.php"; 

	?>
</body>
</html>