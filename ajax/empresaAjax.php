<?php
	$peticionAjax=true;

	require_once "../core/configGeneral.php";
	
	if(isset($_POST['precio-reg']) || isset($_POST['gasto-reg'])){
		require_once "../controladores/empresaControlador.php";
		$empresa= new empresaControlador();

		if(isset($_POST['precio-reg'])){
			echo $empresa->finalizar_sesion_controlador();
		}

		if(isset($_POST['gasto-reg'])){
			echo $empresa->finalizar_sesion_controlador();
		}

		
	}else{
		session_start(['name'=>'PLATANERATAB']);
		session_destroy();
		echo '<script>window.location.href="'.SERVERURL.'login/"</script>';

	}