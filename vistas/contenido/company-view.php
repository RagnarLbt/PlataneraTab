		<section class="full-width header-well">
			<div class="full-width header-well-icon">
				<i class="zmdi zmdi-truck"></i>
			</div>
			<div class="full-width header-well-text">
				<h1 class="text-condensedLight">
					Embarques
				</h1>
			</div>
		</section>

		<?php 
			$fecha=date("Y-m-d");
			$n="Algo";
			require_once "./controladores/productorControlador.php";
			$objProductor= new productorControlador();

			$productorData=$objProductor->listaProductorControlador();

			if($n==""){
		?>
		<div class="full-width divider-menu-h"></div>
		<div class="mdl-grid">
			<div class="mdl-cell mdl-cell--12-col">
				<div class="full-width panel mdl-shadow--2dp">
					<div class="full-width panel-tittle bg-primary text-center tittles">
						Nuevo Embarque
					</div>
					<div class="full-width panel-content">
						<form>
							<div class="mdl-grid">
								<div class="mdl-cell mdl-cell--12-col">
		                            <legend class="text-condensedLight text-center"><i class="zmdi zmdi-border-color"></i> &nbsp; DATOS DEL EMBARQUE</legend><br>
		                        </div>
		                        <div class="mdl-cell mdl-cell--4-col mdl-cell--2-col-tablet"></div>
		                        <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
		                        	<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
		                        		<input type="date" class="mdl-textfield__input" value="<?php echo $fecha; ?>">
		                        		<label class="mdl-textfield__label"><i class="zmdi zmdi-truck"></i> &nbsp;Fecha de Inicio</label>
										<span class="mdl-textfield__error">Fecha Invalida</span>
		                        	</div>
		                        </div>
		                        <div class="mdl-cell mdl-cell--4-col mdl-cell--2-col-tablet"></div>
							</div>
							<p class="text-center">
								<button class="mdl-button mdl-js-button bg-primary text-white" id="btn-addCompany">
									<i class="zmdi zmdi-save"></i> &nbsp; Iniciar
								</button>
								<div class="mdl-tooltip" for="btn-addCompany">Iniciar Embarque</div>
							</p>
						</form>
					</div>
				</div>
			</div>
		</div>

	<?php }else{ ?>
		<div class="mdl-grid">
			<div class="mdl-cell mdl-cell--12-col">
				<div class="full-width panel mdl-shadow--2dp">
					
					<div class="mdl-tabs__tab-bar">
						<a href="#tabNewPayment" class="mdl-tabs__tab is-active">PROVEEDOR</a>
						<a href="#tabListBolseros" class="mdl-tabs__tab">LISTA DE BOLSEROS</a>
						<a href="#tabListPeladores" class="mdl-tabs__tab">LISTA DE PELADORES</a>
					</div> 
					
					<div class="mdl-tabs__panel is-active" id="tabNewPayment">
						<div class="mdl-grid">
							<div class="mdl-cell mdl-cell--12-col">
								<div class="full-width panel ">
									<div class="full-width panel-content">
										<form>
											<div class="mdl-grid">
												<div class="mdl-cell mdl-cell--4-col">
													<div class="mdl-textfield mdl-js-textfield">
														<select class="mdl-textfield__input" name="tipo-reg-trabaj">
															<option value="" disabled="" selected="">Productores...</option>

															<?php foreach ($productorData as $row) { ?>
																<option value="<?php echo $row['id']; ?>"><?php echo $row['nombre']." ".$row['Ap_p']." ".$row['Ap_m']; ?></option>
															<?php } ?>

														</select>
													</div>
												</div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabaj" autofocus="">
														<label class="mdl-textfield__label">Proveedor</label>
														<span class="mdl-textfield__error">Proveedor</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabaj">
														<label class="mdl-textfield__label" for="apellidoPaterno">Apellido Paterno</label>
														<span class="mdl-textfield__error">Apellido invalido</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-trabaj">
														<label class="mdl-textfield__label" for="apellidoMaterno">Apellido Materno</label>
														<span class="mdl-textfield__error">Apellido invalido</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col">
													<div class="mdl-textfield mdl-js-textfield">
														<select class="mdl-textfield__input" name="tipo-reg-trabaj">
															<option value="" disabled="" selected="">Tipo de Trabajo</option>
															<option value="2">Bosero</option>
															<option value="1">Pelador</option>
														</select>
													</div>
												</div>
											    <!--div class="mdl-cell mdl-cell--6-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-záéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="descriptionPayment">
														<label class="mdl-textfield__label" for="descriptionPayment">Description</label>
														<span class="mdl-textfield__error">Invalid description</span>
													</div>
											    </div mdl-button--fab mdl-js-ripple-effect mdl-button--colored-->
											</div>
											<p class="text-center">
												<button class="mdl-button mdl-js-button bg-primary text-white" id="btn-addPayment">
													&nbsp; Registrar &nbsp;
													<i class="zmdi zmdi-save"></i>
												</button>
												<div class="mdl-tooltip" for="btn-addPayment">Registrar Trabajador</div>
											</p>

											<div class="RespuestaAjax"></div>
										</form>
									</div>
								</div>
							</div>
						</div>
					</div> 
					<div class="mdl-tabs__panel is-active" id="tabNewPayment">
						<div class="mdl-grid">
							<div class="mdl-cell mdl-cell--12-col">
								<div class="full-width panel ">
									<div class="full-width panel-content">
										<form>
											<div class="mdl-grid">
												<div class="mdl-cell mdl-cell--4-col">
													<div class="mdl-textfield mdl-js-textfield">
														<select class="mdl-textfield__input" name="tipo-reg-trabaj">
															<option value="" disabled="" selected="">Productores...</option>

															<?php foreach ($productorData as $row) { ?>
																<option value="<?php echo $row['id']; ?>"><?php echo $row['nombre']." ".$row['Ap_p']." ".$row['Ap_m']; ?></option>
															<?php } ?>

														</select>
													</div>
												</div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabaj" autofocus="">
														<label class="mdl-textfield__label">Proveedor</label>
														<span class="mdl-textfield__error">Proveedor</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabaj">
														<label class="mdl-textfield__label" for="apellidoPaterno">Apellido Paterno</label>
														<span class="mdl-textfield__error">Apellido invalido</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-trabaj">
														<label class="mdl-textfield__label" for="apellidoMaterno">Apellido Materno</label>
														<span class="mdl-textfield__error">Apellido invalido</span>
													</div>
											    </div>
											    <div class="mdl-cell mdl-cell--4-col">
													<div class="mdl-textfield mdl-js-textfield">
														<select class="mdl-textfield__input" name="tipo-reg-trabaj">
															<option value="" disabled="" selected="">Tipo de Trabajo</option>
															<option value="2">Bosero</option>
															<option value="1">Pelador</option>
														</select>
													</div>
												</div>
											    <!--div class="mdl-cell mdl-cell--6-col mdl-cell--8-col-tablet">
													<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
														<input class="mdl-textfield__input" type="text" pattern="-?[A-Za-záéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="descriptionPayment">
														<label class="mdl-textfield__label" for="descriptionPayment">Description</label>
														<span class="mdl-textfield__error">Invalid description</span>
													</div>
											    </div mdl-button--fab mdl-js-ripple-effect mdl-button--colored-->
											</div>
											<p class="text-center">
												<button class="mdl-button mdl-js-button bg-primary text-white" id="btn-addPayment">
													&nbsp; Registrar &nbsp;
													<i class="zmdi zmdi-save"></i>
												</button>
												<div class="mdl-tooltip" for="btn-addPayment">Registrar Trabajador</div>
											</p>

											<div class="RespuestaAjax"></div>
										</form>
									</div>
								</div>
							</div>
						</div>
					</div>					
				</div>
			</div>
		</div>
	<?php } ?>
	</section>
</body>
</html>