	<div class="login-wrap cover">
		<div class="container-login">
			<p class="text-center" style="font-size: 70px;">
				<i class="zmdi zmdi-account-circle"></i>
			</p>
			<h4 class="text-center text-condensedLight">Iniciar Sesión</h4>
			<!--form action="<?php echo SERVERURL; ?>home/"-->
			<div id="login">
				<div class="form-group">
					<label>Nombre de Usuario</label>
					<input type="text" class="form-control" v-model="userName" autofocus>
				</div>
				<div class="form-group">
					<label>Contraseña</label>
					<input type="password" v-model="userPass" class="form-control">
				</div>
				<div class="form-group col-sm-4 mx-auto">
					<button class="btn bg-primary text-white" @click="btnIniciar()">Ingresar</button>
				</div>
			</div>
			<!--/form-->
		</div>
	</div>