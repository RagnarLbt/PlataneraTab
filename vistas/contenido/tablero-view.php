<div class="tablero">
	<?php
		$datos=explode("/", $_GET['views']);
		$fecha=$datos[2].'-'.$datos[3].'-'.$datos[4];
		
		$ec=new embarqueControlador();
		$datos=$ec->listaBosasDia($datos[1], $fecha);
	?>
</div>