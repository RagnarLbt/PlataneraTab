	<div class="full-box login-container cover">
		<form action="" method="POST" autocomplete="off" class="logInForm">
			<p class="text-center text-muted"><i class="zmdi zmdi-account-circle zmdi-hc-5x"></i></p>
			<p class="text-center text-muted text-uppercase">Inicia sesión</p>
			<div class="form-group label-floating">
				<label class="control-label" for="UserName">Usuario</label>
				<input required="" class="form-control" id="UserName" name="usuario" type="text" autofocus="" style="color: #2e7d32;">
				<!--p class="help-block">Escribe tú nombre de usuario</p-->
			</div>
			<div class="form-group label-floating">
				<label class="control-label" for="UserPass">Contraseña</label>
				<input required="" class="form-control" id="UserPass" name="clave" type="password" style="color: #2e7d32;">
				<!--p class="help-block">Escribe tú contraseña</p-->
			</div>
			<div class="form-group text-center">
				<button class="btn btn-danger">Iniciar Sesión</button>
			</div>
		</form>
	</div>
	

	<?php
	if (isset($_POST['usuario']) && isset($_POST['clave'])) {
		require_once "./controladores/loginControlador.php";
		$login= new loginControlador();
		echo $login->iniciar_sesion_controlador();
	}
	
	?>