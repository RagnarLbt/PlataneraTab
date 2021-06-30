<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><?php echo COMPANY; ?></title>
	<link rel="icon" href="<?php echo SERVERURL; ?>vistas/assets/icons/bananas.png" type="image/png" />
	<link rel="stylesheet" href="<?php echo SERVERURL; ?>vistas/css/main.css">
</head>
<body>

	<?php
		$peticionAjax=false;

		require_once "./controladores/vistasControlador.php";
		$vt= new vistasControlador();
		$vistasR=$vt->obtener_vistas_controlador();
		$filejs=$vt->obtener_js_controlador();

		if($vistasR == "./vistas/contenido/login-view.php" || $vistasR == "login"){
			
			include "./vistas/modulos/scripts.php";
			require_once "./vistas/contenido/login-view.php";
		
		}elseif($vistasR == "./vistas/contenido/tablero-view.php" || $vistasR == "tablero"){
			require_once "./controladores/embarqueControlador.php";
			$ec= new embarqueControlador();

			require_once "./vistas/contenido/tablero-view.php";
			
			include "./vistas/modulos/scripts.php";
			
		}else{

			session_start(['name'=>'PLATANERATAB']);

			require_once "./controladores/loginControlador.php";
			$lc= new loginControlador();


			if(!isset($_SESSION['token']) || !isset($_SESSION['user_name'])){
				$lc->cerrar_sesion_controlador();
			}


			require_once "./vistas/modulos/lateralMenu.php";
	?>
				<section id="container" class="">				
				    <!-- Content page -->
				    <?php 
				    require_once $vistasR;
				    //require_once "./vistas/js/scripts.php";
				    ?>
				</section>
			</section>
	<?php 
			require_once "./vistas/modulos/scripts.php";
			include "./vistas/modulos/logoutScript.php";
	?>
			<script>
				<?php require_once $filejs; ?> 
			</script>
	<?php
		}
	?>

</body>
</html>