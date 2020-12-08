<!--ALTER TABLE nombre_tabla AUTO_INCREMENT = 1-->

	<div id="embarques">
		<section class="container-fluid mt-2 mb-1">
			<div class="row">
				<div class="col-sm-12 col-md-4 text-center">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-truck"></i> &nbsp; Embarque {{embActual}}</h1>
				</div>
				<div class="col-sm-6 col-md-4 mt-2">
					<div class="form-inline justify-content-center">
						<div class="form-group">
							<!--Lista de embarques actuales-->
							<label>No. Emb.</label>
							<select class="custom-select custom-select-sm mx-sm-3" v-model="selected">
								<option v-if="listaEmbarques == ''">Sin datos...</option>
								<option v-for="lista of listaEmbarques" :key="lista.id">{{lista.id}}</option>
							</select>
						</div>
						<!--Cargar los datos de embarque seleccionado-->
						<button @click="btnCargarDatos" class="btn btn-warning btn-sm text-white"><i class="zmdi zmdi-search-in-page"></i>&nbsp;Crargar..</button>
					</div>
				</div>
				<div class="col-sm-6 col-md-4 mt-2">
					<!--Formulario para crear un nuevo embarque-->
					<button class="btn btn-info btn-sm" @click="btnNuevoEmbarque"><i class="zmdi zmdi-truck"></i>&nbsp; Crear Embarque</button>
				</div>
			</div>
		</section>

		<section class="container-fluid col-sm-12 mb-4 d-flex justify-content-center p-2" v-if="embActual != ''">
			<div class="form-inline">
				<div class="form-group">
					<label>No. Bolsas</label>
					<input type="text" disabled readonly class="form-control mx-sm-3 form-control-plaintext pl-3" v-model="noBolsas">
				</div>
				<div class="form-group">
					<label>Día</label>
					<input type="text" disabled readonly class="form-control mx-sm-3 form-control-plaintext pl-3" v-model="fecha_dia">
				</div>
				<button  class="btn btn-outline-danger m-md-2" @click="btnVerResumen()"><i class="zmdi zmdi-calendar-alt"></i>&nbsp;Finalizar Día</button>
			</div>
		</section>

		<!--Resumen del día -->
		<div id="resumen" class="col-sm-12 mb-5" style="display: none;">
			<div class="row container-fluid d-block justify-content-center mt-3">
				<div class="col-sm-12 table-responsive-sm">
					<table class="text-dark table table-hover table-sm">
						<thead class="thead-dark">
							<tr>
								<th colspan="2" class="text-center">Resumen del día</th>
							</tr>
						</thead>
						<tbody class="table" id="tablass" v-for="lista of listaResumen">
							<tr>
								<td class="text-left">Cantidad de bolsas</td>
								<td class="text-right">{{lista.bolsas}}</td>
							</tr>
							<tr>
								<td class="text-left">Toneladas fruta</td>
								<td class="text-right">{{lista.kilos}}</td>
							</tr>
							<tr>
								<td class="text-left">Gastos hasta el día</td>
								<td class="text-right">$ {{lista.total_gastos}}</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-sm-12 text-center d-flex justify-content-center">
					<div class="row">
						<button type="submit" class="btn-sm btn btn-outline-danger mb-2"  @click="finalizarCancelar()"><i class="zmdi zmdi-close-circle"></i>&nbsp;Cancelar</button>&nbsp;
						<button type="submit" class="btn btn-sm btn-info mb-2"  @click="finalizarDia()"><i class="zmdi zmdi-save"></i>&nbsp;Finalizar</button>&nbsp;									
						<form method="POST" action="<?php echo SERVERURL; ?>vistas/contenido/resumen-view.php" target="_blank">
							<input type="hidden" v-model="fecha_dia" name="fechaAct">
							<input type="hidden" v-model="embActual" name="idEmbarque">
							<input type="hidden" value="<?php echo $_SESSION['nombre']; ?>" name="user">
							<button type="submit" class="col-sm-12 btn btn-sm btn-danger mb-2"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
						</form>
					</div>
				</div>
			</div>
		</div>
		
		<div class="container-fluid" v-if="embActual != ''">
			<ul class="nav nav-pills mb-3 justify-content-center" id="pills-tab" role="tablist">
				<li class="nav-item">
					<a class="nav-link active" id="pills-proveedores-tab" data-toggle="pill" href="#pills-proveedores" role="tab" aria-controls="pills-proveedores" aria-selected="true">REGISTRO DE FRUTA</a>
				</li>
				<li class="nav-item">
					<a class="nav-link" id="pills-planilla-tab" data-toggle="pill" href="#pills-planilla" role="tab" aria-controls="pills-planilla" aria-selected="false">PLANILLA TOSTON</a>
				</li>
				<li class="nav-item">
					<a class="nav-link" id="pills-trabajadores-tab" data-toggle="pill" href="#pills-trabajadores" role="tab" aria-controls="pills-trabajadores" aria-selected="false">BOLSEROS</a>
				</li>
				<li class="nav-item">
				    <a class="nav-link" id="pills-contact-tab" data-toggle="pill" href="#pills-lista" role="tab" aria-controls="pills-lista" aria-selected="false">PELADORES</a>
				</li>
				<li class="nav-item">
				    <a class="nav-link" id="pills-bolsas-tab" data-toggle="pill" href="#pills-bolsas" role="tab" aria-controls="pills-bolsas" aria-selected="false">BOLSAS DEL DIA</a>
				</li>
				<li class="nav-item">
				    <a class="nav-link" id="pills-finalizar-tab" data-toggle="pill" href="#pills-finalizar" role="tab" aria-controls="pills-finalizar" aria-selected="false">FINALIZAR EMBARQUE</a>
				</li>
			</ul>
				
			<div class="container-fluid tab-content " id="pills-tabContent">
				
				<!--Formulario Ingreso de fruta al embarque-->
				<div class="tab-pane fade show active" id="pills-proveedores" role="tabpanel" aria-labelledby="pills-proveedores-tab">
					<div class="col-sm-12 card border rounded">
						<div class="row mb-2">
							<div class="col-sm-12 m-1">
								<!--Datos de la fruta-->
								<div class="card-header p-1 bg-info text-white text-center titles">Peso de Fruta</div>
								<div class="col-sm-12 mt-1" id="boton_captura" style="display: block; ">
									<button @click="autenticar('', '', '', '', '',1)" class="btn btn-sm btn-warning text-center mb-1"><i class="zmdi zmdi-eye"></i>&nbsp; Capturar Fruta</button>
									<button @click="autenticar('', '', '', '', '',3)" class="btn btn-sm btn-success text-center mb-1"><i class="zmdi zmdi-eye"></i>&nbsp; Adeudo</button>
									<button @click="autenticar('', '', '', '', '',4)" class="btn btn-sm btn-secondary text-center mb-1"><i class="zmdi zmdi-eye"></i>&nbsp; Abonar</button>
								</div>
								<div class="col-sm-12 mt-1" id="bontonAtras" style="display: none;">
									<div>
										<button @click="btnVolverCaptura()" class="btn btn-sm btn-danger text-center mb-1"><i class="zmdi zmdi-eye-off"></i>&nbsp; Cerrar</button>
									</div>
								</div>

								<div class="col-sm-12 row p-3 offset-md-1">
									<div class="col-sm-6">
										<input type="hidden" v-model="fecha_dia" name="fechaAct">
										<input type="hidden" v-model="embActual" name="idEmbarque">
										
										<!-- Registro de Fruta -->
										<div id="pesar_fruta">
											<div id="peso_balanza" class="form-inline col-sm-12 mt-2">
												<label for="nombre" class="text-right form-control-label col-sm-4">Peso</label>
												<input type="number" step="0.1" class="form-control col-sm-7 col-md-7" placeholder="Peso (Kg´s)"  v-model="peso">
											</div>
											<div id="compra_peso" class="form-inline col-sm-12 mt-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Compra</label>
												<input type="number" step="0.1" class="form-control col-sm-7 col-md-7" placeholder="Precio $"  v-model="pagoFruta">
											</div>
											<div id="prod_pesas" class="form-inline col-sm-12 mt-3 mb-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Productor</label>
												<select class="custom-select col-sm-7 col-md-7" @click="listaFrutaProd(idProd, embActual)" name="idProductor" v-model="idProd">
													<option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
													{{lp.id}} - {{lp.nombre}} {{lp.Ap_p}}</option>
												</select>
											</div>
											<div class="col-sm-12 row">
												<div class="col-sm-6 text-center">
													<br>
													<h2>Total: {{totalPesoProductor}} Kg</h2>
												</div>
												<div class="col-sm-6 text-center">
													<br>
													<h2>Rend: {{prodRend}}</h2>
												</div>
											</div>
										</div>
										
										<!-- Capturar Fruta  -->
										<div id="captura_fruta" style="display: none;">
											<div id="peso_balanza" class="form-inline col-sm-12 mt-2">
												<label for="nombre" class="text-right form-control-label col-sm-4">Peso</label>
												<input type="number" step="0.1" class="form-control col-sm-7 col-md-7" placeholder="Peso (Kg´s)"  v-model="peso_captura">
											</div>
											<div id="compra_peso" class="form-inline col-sm-12 mt-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Compra</label>
												<input type="number" step="0.1" class="form-control col-sm-7 col-md-7" placeholder="Precio $"  v-model="pagoFruta">
											</div>
											<div id="prod_captura" class="form-inline col-sm-12 mt-3 mb-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Productor</label>
												<select class="custom-select col-sm-7 col-md-7" name="idProductor" v-model="idProd">
													<option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
													{{lp.id}} - {{lp.nombre}} {{lp.Ap_p}}</option>
												</select>
											</div>
											<div class="form-inline col-sm-12 mt-3">
												<label for="fecha" class="text-right form-control-label col-sm-4">Fecha</label>
												<input type="date" class="form-control col-sm-7 col-md-7" v-model="fecha_dia">
											</div>
										</div>

										<div id="prestamo" style="display: none;">
											<div id="prod_prestamo" class="form-inline col-sm-12 mt-3 mb-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Productor</label>
												<select class="custom-select col-sm-7 col-md-7" name="idProductor" v-model="idProd">
													<option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
													{{lp.id}} - {{lp.nombre}} {{lp.Ap_p}}</option>
												</select>
											</div>
											<div id="prest_tipo">
												<div class="form-inline col-sm-12 mt-3 mb-3">
													<label class="col-sm-4 col-md-4 text-center text-dark">Préstamo</label>
													<select class="custom-select col-sm-7 col-md-7" name="prestamoTipo" v-model="prestamo_tipo">
														<option value="1">Fungicida</option>
														<option value="2">Fertilizante</option>
														<option value="3">Préstamo</option>
													</select>
												</div>
											</div>
											<div id="prest_cantidad">
												<div class="form-inline col-sm-12 mt-3">
													<label for="fecha" class="text-right form-control-label col-sm-4">Cantidad</label>
													<input type="number" step="0.01" class="form-control col-sm-7 col-md-7" v-model="prestamo_cantidad">
												</div>
											</div>
											<div id="prest_cantidad">
												<div class="form-inline col-sm-12 mt-3">
													<label for="fecha" class="text-right form-control-label col-sm-4">No. Pagos</label>
													<input type="number" step="0.01" class="form-control col-sm-7 col-md-7" v-model="no_pagos">
												</div>
											</div>
											<div id="boton_reg_prestamo">
												<div class="col-sm-12 text-center mt-3">
													<button @click="regPrestamo()" class="btn btn-sm btn-success"><i class="zmdi zmdi-save"></i>&nbsp; Registrar</button>
												</div>
											</div>
										</div>

										<div id="abono" style="display: none;">
											<div id="prod_abono" class="form-inline col-sm-12 mt-3 mb-3">
												<label class="col-sm-4 col-md-4 text-center text-dark">Productor</label>
												<select @click="datosPrestamo(idProd)" class="custom-select col-sm-7 col-md-7" name="idProductor" v-model="idProd">
													<option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
													{{lp.id}} - {{lp.nombre}} {{lp.Ap_p}}</option>
												</select>
											</div>
											<div v-if="datosSaldos != ''">
												<div v-for="ls of datosSaldos">
													<div class="form-inline col-sm-12 mt-3 mb-3">
														<label class="col-sm-4 col-md-4 text-center text-dark">Préstamo</label>
														<select class="custom-select col-sm-7 col-md-7" name="pretamoTipo" v-model="prestamo_tipo">
															<option v-if="ls.sfun>0" value="1">Fungicida</option>
															<option v-if="ls.sfer>0" value="2">Fertilizante</option>
															<option v-if="ls.sp>0" value="3">Préstamo</option>
														</select>
													</div>

													<div id="prest_cantidad">
														<div class="form-inline col-sm-12 mt-3">
															<label for="fecha" class="text-right form-control-label col-sm-4">Cantidad</label>
															<input type="number" step="0" class="form-control col-sm-7 col-md-7" v-model="abono">
														</div>
													</div>
													
													<div class="col-sm-12 row mt-3">
														<label class="col-sm-3"></label>
														<label class="text-right form-control-label col-sm-3">Fungicida</label>
														<label class="text-right form-control-label col-sm-3">Fertilizante</label>
														<label class="text-left form-control-label col-sm-3">Prestamos</label>
													</div>
													<div class="form-inline col-sm-12">
														<label class="text-right form-control-label col-sm-3">Abono</label>
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.abono_fun">
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.abono_fer">
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.abono_p">
													</div>
													<div class="form-inline col-sm-12 mt-3">
														<label class="text-right form-control-label col-sm-3">Saldo Actual</label>
														<input type="text" class="form-control col-sm-3 col-md-3" disabled v-model="ls.sfun">
														<input type="text" class="form-control col-sm-3 col-md-3" disabled v-model="ls.sfer">
														<input type="text" class="form-control col-sm-3 col-md-3" disabled v-model="ls.sp">
													</div>
													<div class="form-inline col-sm-12 mt-3">
														<label class="text-right form-control-label col-sm-3">No. Pagos</label>
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.no_pagos_fungicida">
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.no_pagos_fertilizante">
														<input type="number" step="0.01" class="form-control col-sm-3 col-md-3" disabled v-model="ls.no_pagos_prestamo">
													</div>

												</div>
											</div>
											<div id="boton_reg_abono">
												<div class="col-sm-12 text-center mt-3">
													<button @click="regAbono()" class="btn btn-sm btn-success"><i class="zmdi zmdi-save"></i>&nbsp; Registrar</button>
												</div>
											</div>
											</div>

										<div id="boton_guardar" style="display: none">
											<div class="col-sm-12 text-center mt-3">
												<button @click="btnCapturaManual(idProd, peso_captura, pagoFruta)" class="btn btn-sm btn-success"><i class="zmdi zmdi-save"></i>&nbsp; Registrar</button>
											</div>
										</div>
									</div>

									<div class="col-sm-4 text-right" id="cargar_camara">
										<div id="my_camera" class="col-sm-12"></div>
										<div id="pre_take_buttons" class="mt-1 text-center">
											<button class="btn btn-sm btn-info" @click="foto(idProd, peso)"><i class="zmdi zmdi-camera"></i>&nbsp; Capturar foto</button>
										</div>
										<div id="post_take_buttons" class="mt-1 text-center" style="display:none">
											<button class="btn btn-sm btn-danger" @click="cancel_preview()"><i class="zmdi zmdi-close-circle"></i>&nbsp; Capturar de nuevo</button>
											<button class="btn btn-sm btn-success" @click="save_photo(idProd, peso)" style="font-weight:bold;"><i class="zmdi zmdi-save"></i>&nbsp; Guardar</button>
										</div>
									</div>
								</div>
								<!--=====================================
								=            Listado de pesas realizadas            =
								======================================-->
								<div class="rounded card-header p-1 bg-info text-white text-center titles">Pesas Registradas
								</div>

								<div class="col-sm-12 mt-2" id="listaPesasCapturadas" style="display: none;">
									<div class="row">
										<table class="text-dark rounded-0 table table-hover table-sm table-bordered">
											<thead class="thead-dark">
												<th class="text-center">Productor</th>
												<th class="text-center">Pago</th>
												<th class="text-center">Peso</th>
												<th class="text-center"></th>
											</thead>
											<tbody>
												<tr v-for="list in pesasCapturadas">
													<td>{{list.id_productores}} - {{list.nombre}}</td>
													<td class="text-right">$ {{list.pago}}</td>
													<td class="text-right">{{list.peso}} Kg</td>
													<td class="text-center">
														<button @click="btnModificarPeso(list.id_fruta, list.id, list.nombre, list.peso, list.pago)" class="btn btn-sm btn-outline-success"><i class="zmdi zmdi-refresh-sync"></i></button>&nbsp;
														<button @click="btnEliminarPeso(list.peso, list.nombre, list.id_fruta, list.id, list.pago)" class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-close-circle"></i></button>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
									<hr>
								</div>

								<div id="fotos_pesas">
									<div class="col-sm-12 text-right">
										<form class="" method="POST" action="<?php echo SERVERURL; ?>vistas/contenido/factura-view.php" target="_blank">
											<input type="hidden" v-model="idProd" name="idProductor">
											<input type="hidden" v-model="fecha_dia" name="fechaAct">
											<input type="hidden" v-model="embActual" name="idEmbarque">
											<input type="hidden" value="<?php echo $_SESSION['nombre']; ?>" name="user">
											<button class="btn btn-sm btn-danger" type="submit"><i class="zmdi zmdi-download text-white"></i>&nbsp;Generar PDF</button>
										</form>
									</div>
									<div class="col-sm-12 form-inline">
										<div class="col-sm-4 col-md-3 col-lg-2 mb-1" v-for="list of listaFrutaP">
											<div class="card text-center">
												<img v-bind:src="list.foto" class="card-img-top" alt="Card image cap">
												<div class="card-body">
													<p class="card-text">Peso: {{list.peso}} kg</p>
												</div>
											</div>
										</div>
									</div>
								</div>

								<!--====  End of Listado de pesas realizadas  ====-->
							</div>
						</div>
					</div>
				</div>

				<!-- Planilla Toston: Registro de Pagos diarios a la Planilla -->
				<div class="tab-pane fade" id="pills-planilla" role="tabpanel" aria-labelledby="pills-planilla-tab">
					<div class="row">
						<div class="col-sm-12">
							
							<div class="row col-sm-12 mt-1 p-2">
								<div class="col-sm-6">
									<p class="form-inline">Buscar: &nbsp; 
										<input class="form-control col-sm-8 col-md-4" type="number" placeholder="Buscar..." v-model="filtro_3">
									</p>
								</div>
							</div>

							<div class="row container-fluid d-flex justify-content-center mt-3">
								<div class="col-sm-12 table-sm">
									<table class="text-dark table table-hover table-sm">
										<thead class="thead-dark">
											<tr>
												<th class="text-center">ID</th>
												<th class="text-center">Nombre</th>
												<th class="text-center">Tipo</th>
												<th class="text-center">Opciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="listaPT in search3">
												<td class="text-center">{{listaPT.id}}</td>
												<td class="text-center">{{listaPT.nombre}} {{listaPT.ap_p}} {{listaPT.ap_m}}</td>
												<td class="text-center">
													<p>Planilla Toston</p>
												</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnPagoPlanilla(listaPT.id, listaPT.tipo)">
														<i class="zmdi zmdi-money"></i>&nbsp;Pagar
													</button>&nbsp;
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>

						</div>
					</div>
				</div>
				
				<!--Lista de Bolseros, para registrar a los trabajadores del día-->
				<div class="tab-pane fade" id="pills-trabajadores" role="tabpanel" aria-labelledby="pills-trabajadores-tab">
					<div class="row">
						<div class="col-sm-12">
							
							<div class="row container-fluid d-flex justify-content-center mt-3">

								<div class="col-sm-6 table-sm p-1 mr-1">
									<p class="form-inline text-center">Buscar: &nbsp; 
										<input class="form-control col-sm-5" type="number" placeholder="Buscar Bolsero..." v-model="filtro">
									</p>
									<table class="text-dark table table-hover table-sm">
										<thead class="text-white">
											<tr class="bg-success">
												<th class="text-center" colspan="3">Bolseros</th>
											</tr>
											<tr class="bg-success">
												<th class="text-center">ID</th>
												<th class="text-center">Nombre</th>
												<th class="text-center">Opciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="listaD in search">
												<td class="text-center">{{listaD.id}}</td>
												<td class="text-left">{{listaD.nombre}} {{listaD.Ap_p}} {{listaD.Ap_m}}</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnAsistencia(listaD.id, pagoBolsero)">
														<i class="zmdi zmdi-check"></i>&nbsp;Asistencia
													</button>&nbsp;
													<button class="btn btn-outline-primary btn-sm"  @click="btnAsignarTrabajo(listaD.id)">
														<i class="zmdi zmdi-case"></i>&nbsp;Otro Trabajo
													</button>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								
								<div class="col-sm-5 table-sm rounded p-1">
									<div class="mb-3 d-flex justify-content-md-end">
										<button @click="bolseroExtra(fecha_dia)" class="btn btn-secondary col-sm-12 col-md-5"><i class="zmdi zmdi-account-add"></i>&nbsp; Pers. Extra</button>
									</div>
									<table v-if="listaExtra.length>=1" class="mb-2 text-dark table table-hover table-sm">
										<thead class="text-white">
											<tr class="bg-secondary">
												<th class="text-center" colspan="4">Personal Extra</th>
											</tr>
											<tr class="bg-secondary">
												<th class="text-center">Nombre</th>
												<th class="text-center">Trabajo</th>
												<th class="text-center">Fecha</th>
												<th class="text-center">Opciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="lis in listaExtra">
												<td class="text-left">{{lis.nombre}} {{lis.apellidos}}</td>
												<td class="text-left">{{lis.actividad}}</td>
												<td class="text-left">{{lis.fecha}}</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnModExtra(lis.id, lis.nombre, lis.apellidos, lis.edad, lis.telefono, lis.direccion, lis.cuenta, lis.actividad, lis.pago, lis.fecha)">
														<i class="zmdi zmdi-refresh-sync"></i>
													</button>&nbsp;
													<button class="btn btn-outline-danger btn-sm"  @click="btnDelExtra(lis.id, lis.pago)">
														<i class="zmdi zmdi-delete"></i>
													</button>
												</td>
											</tr>
										</tbody>
									</table>

									<table v-if="trabajosExtras.length>=1" class="text-dark table table-hover table-sm mt-2">
										<thead class="text-white">
											<tr class="bg-primary">
												<th class="text-center" colspan="4">Otros Trabajos</th>
											</tr>
											<tr class="bg-primary">
												<th class="text-center">Nombre</th>
												<th class="text-center">Trabajo</th>
												<th class="text-center">Fecha</th>
												<th class="text-center">Opciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="lis in trabajosExtras">
												<td class="text-left">{{lis.nombre}}</td>
												<td class="text-left">{{lis.actividad}}</td>
												<td class="text-left">{{lis.fecha}}</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnModOtroTrab(lis.id, lis.id_bolsero, lis.actividad, lis.fecha, lis.pago, lis.idExtra)">
														<i class="zmdi zmdi-refresh-sync"></i>
													</button>&nbsp;
													<button class="btn btn-outline-danger btn-sm"  @click="btnDelOtroTrab(lis.id, lis.pago, lis.idExtra, lis.fecha)">
														<i class="zmdi zmdi-delete"></i>
													</button>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>

						</div>
					</div>
				</div>

				<!--Lista de peladores, donde se agregaran bolsas al embarque actual-->
				<div class="tab-pane fade" id="pills-lista" role="tabpanel" aria-labelledby="pills-lista-tab">
					<div class="row">
						<div class="col-sm-12">
							<!--================================================
							=            Condigo para Filtar Tablas            =
							=================================================-->
							
							<div class="row p-2" id="peladorVer">
								<div class="col-md-4">
									<p id="a" class="form-inline">Buscar: &nbsp; 
										<input class="form-control col-sm-8 col-md-4 peladorVer" id="filtro" autocomplete="off" type="text" placeholder="Buscar..." v-model="filtro_2">
									</p>
								</div>
								<div class="col-sm-4">
									<h4>Bolsas del día: {{total_dia_bolsas}}</h4>
								</div>
								<div class="col-md-4 text-right">
									<button  class="btn btn-outline-warning m-md-2 " id="tablero" @click="btnTablero()"><i class="zmdi zmdi-eye"></i>&nbsp;Ver Tablero</button>
								</div>
							</div>
							
							<!--====  End of Condigo para Filtar Tablas  ====-->

							<div class="row container-fluid d-block justify-content-center mt-3"  id="tablaP">
								<div class="row container-fluid d-block justify-content-center mt-3">
									<div class="col-sm-12 table-responsive-sm">
										<table class="text-dark table table-hover table-sm">
											<thead class="thead-dark">
											<tr class="bg-secondary">
												<th class="text-center" colspan="6">Peladores</th>
											</tr class="bg-secondary">
												<tr>
													<th class="text-center">ID</th>
													<th class="text-center">Nombre</th>
													<th class="text-center"># Bolsas</th>
													<th class="text-center">Bolsero</th>
													<th class="text-center">Productor</th>
													<th class="text-center">Acciones</th>
												</tr>
											</thead>
											<tbody class="table">
												<tr v-for="listaP in search2" v-if="listaP.estado<1">
													<td class="text-center">{{listaP.id}}</td>
													<td class="text-left">{{listaP.nombre}}</td>
													<td class="text-left">{{listaP.bolsas}}</td>
													<td class="text-center">
														<select class="form-control" v-model="id_bolsero">
															<option v-for="bolseros in listaBolserosTodos" :key="bolseros.id " v-bind:value="bolseros.id">
																{{bolseros.id}}-{{bolseros.nombre}}
															</option>
														</select>
													</td>
													<td class="text-center">
														<select class="form-control" v-model="id_productor">
															<option v-for="fruta in listaFruta" :key="fruta.id_f" v-bind:value="fruta.id_f">
																{{fruta.id_f}}-{{fruta.nombre}}
															</option>
														</select>
													</td>
													<td class="text-center">
														<button class="btn btn-outline-success btn-sm"  @click="btnAddBolsa(listaP.id, listaP.nombre)">
															<i class="zmdi zmdi-plus-circle"></i>&nbsp;Añadir Bolsa
														</button>&nbsp;
														<button class="btn btn-outline-secondary btn-sm"  @click="capturaBolsas(listaP.id)">
															<i class="zmdi zmdi-plus-circle"></i>&nbsp;Capturar Bolsas
														</button>&nbsp;
														<button class="btn btn-outline-primary btn-sm"  @click="btnNewTrabajo(listaP.id)">
														<i class="zmdi zmdi-case"></i>&nbsp;Otro Trabajo
													</button>
													</td>
												</tr>
											</tbody>
										</table>
									</div> <br> <br>

									<!-- Otro trabajo-->
									<div class="col-sm-12 table-responsive-sm">
										<table id="tablas" class="text-dark table table-hover table-sm">
											<thead class="text-white">
											<tr class="bg-primary">
												<th class="text-center" colspan="6">Trabajos extra</th>
											</tr >
												<tr class="bg-primary">
													<th class="text-center">ID</th>
													<th class="text-center">Nombre</th>
													<th class="text-center">Trabajo</th>
													<th class="text-center">Pago</th>
													<th class="text-center">Fecha</th>
													<th class="text-center">Acciones</th>
												</tr>
											</thead>
											<tbody class="table" id="tablass">
												<tr v-for="listaP of listaExtras">
													<td class="text-center">{{listaP.id}}</td>
													<td class="text-left">{{listaP.nombre}} </td>
													<td class="text-center">{{listaP.concepto}}</td>
													<td class="text-right">{{listaP.pago}}</td>
													<td class="text-center">{{listaP.fecha}}</td>
													<td class="text-center">
														<button class="btn btn-outline-primary btn-sm"  @click="btnFinTrabajo(listaP.id, listaP.idE, listaP.idBP)">
															<i class="zmdi zmdi-case"></i>&nbsp;Finalizar Trabajo
														</button>
														<button class="btn btn-outline-success btn-sm" @click="btnUpdatePeladorExtra(listaP.id, listaP.idE, listaP.pago, listaP.trabajo, listaP.concepto, listaP.idBP)">
															<i class="zmdi zmdi-refresh-sync"></i>Editar
														</button>&nbsp;
														<button class="btn btn-outline-danger btn-sm" @click="btnDeletePeladorExtra(listaP.id, listaP.idE, listaP.pago, listaP.idBP)">Eliminar
															<i class="zmdi zmdi-delete"></i>
														</button>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Lista de bolsas diarias producidas -->
				<div class="tab-pane fade" id="pills-bolsas" role="tabpanel" aria-labelledby="pills-bolsas-tab">
					<div class="row">
						
						<div class="col-sm-12">
							<!--================================================
							=            Condigo para Filtar Tablas            =
							=================================================-->
							
							<div class="row col-sm-12 p-2">
								<div class="col-sm-12 col-md-6">
									<p class="form-inline">Buscar: &nbsp; 
										<input class="form-control col-sm-8 col-md-4" id="filtro2" type="text" autocomplete="off" placeholder="Buscar..." v-model="filtro_bolsas">
									</p>
								</div>
							</div>
							
							<!--====  End of Condigo para Filtar Tablas  ====-->

							<div class="row container-fluid d-block justify-content-center mt-3">
								<div class="row container-fluid d-block justify-content-center mt-3">
									<div class="col-sm-12 table-responsive-sm">
										<table class="text-dark table table-hover table-sm">
											<thead class="thead-dark">
												<tr>
													<th class="text-center">#</th>
													<th class="text-center">Nombre</th>
													<th class="text-center">Pelador</th>
													<th class="text-center">Hora</th>
													<th class="text-center">Bolsero</th>
													<th class="text-center">Productor</th>
													<th class="text-center">Acciones</th>
												</tr>
											</thead>
											<tbody class="table" id="tablass">
												<tr v-for="bol in fintroBolsas">
													<td class="text-center">{{bol.numero}}</td>
													<td class="text-lefth">{{bol.nombre}}</td>
													<td class="text-center">{{bol.pelador}}</td>
													<td class="text-center">{{bol.hora}}</td>
													<td class="text-center">{{bol.id_bolsero}}</td>
													<td class="text-center">{{bol.id_productor}}</td>
													<td class="text-center">
														<button class="btn btn-outline-success btn-sm" @click="autenticar(bol.id, bol.numero, bol.id_bolsero, bol.pelador, bol.id_productor, 2)">
															<i class="zmdi zmdi-refresh-sync"></i>&nbsp;Modificar
														</button>
														<button class="btn btn-outline-info btn-sm" @click="reimprimir(bol.numero, bol.id_productor, bol.id_bolsero, bol.pelador, bol.hora, bol.fecha)"><i class="zmdi zmdi-local-printshop"></i>&nbsp;Imprimir
														</button>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!--Formulario para finalizar el embarque-->
				<div class="tab-pane fade" id="pills-finalizar" role="tabpanel" aria-labelledby="pills-finalizar-tab">
					<div class="col-sm-12 card">
						<div class="row mb-5">
							<div class="col-sm-12 card-header p-1 bg-info text-white text-center titles">
								Finalizar Embarque
							</div>
							<div class="col-sm-6 mt-3">
							<!--Datos para cerrar embarque-->
								<div class="form-group row">
									<label for="noBolsas" class="col-sm-4 col-form-label text-dark text-right">Bolsas Etiquetadas</label>
									<div class="col-sm-8">
										<input type="number" disabled class="form-control" v-model="noBolsas" required="" name="noBolsas">
									</div>
								</div>
								<div class="form-group row">
									<label for="noBolsasExistentes" class="col-sm-4 col-form-label text-dark text-right">No. Bolsas</label>
									<div class="col-sm-8">
										<input type="number" @keyup.enter="btnFinalizarEmbarque()" class="form-control" v-model="noBolsasExistentes" required="" name="noBolsasExistentes">
									</div>
								</div>
								<div class="form-group row">
									<label for="rendimiento" class="col-sm-4 col-form-label text-dark text-right">Rendimiento</label>
									<div class="col-sm-8">
										<input name="rendimiento" @keyup.enter="btnFinalizarEmbarque()" type="number" step="0.001" class="form-control" v-model="rendimiento" disabled="" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="fecha" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>
									<div class="col-sm-8">
										<input type="date" @keyup.enter="btnFinalizarEmbarque()" class="form-control" v-model="fecha_fin" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="perdida" class="col-sm-4 col-form-label text-dark text-right">Bolsas Perdidas</label>
									<div class="col-sm-8">
										<input name="perdida" @keyup.enter="btnFinalizarEmbarque()" type="number" step="1" class="form-control" v-model="perdida" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="contenedor" class="col-sm-4 col-form-label text-dark text-right">No. Contenedor</label>
									<div class="col-sm-8">
										<input type="text" @keyup.enter="btnFinalizarEmbarque()" class="form-control" id="contenedor" v-model="contenedor" required="">
									</div>
								</div>
							</div>
							<div class="col-sm-6 mt-3">
								<div class="form-group row">
									<label for="sello" class="col-sm-4 col-form-label text-dark text-right">Sello</label>
									<div class="col-sm-8">
										<input @keyup.enter="btnFinalizarEmbarque()" type="text" class="form-control" id="sello" v-model="sello" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="temperatura" class="col-sm-4 col-form-label text-dark text-right">Temperatura</label>
									<div class="col-sm-8">
										<input @keyup.enter="btnFinalizarEmbarque()" type="number" class="form-control" id="temperatura" v-model="temperatura" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="matricula" class="col-sm-4 col-form-label text-dark text-right">Matricula (Vehiculo)</label>
									<div class="col-sm-8">
										<input @keyup.enter="btnFinalizarEmbarque()" type="text" class="form-control" v-model="matricula" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="conductor" class="col-sm-4 col-form-label text-dark text-right">Nombre Conductor</label>
									<div class="col-sm-8">
										<input @keyup.enter="btnFinalizarEmbarque()" type="text" class="form-control" v-model="conductor" required="">
									</div>
								</div>
								<div class="form-group row">
									<label for="tostonBolsas" class="col-sm-4 col-form-label text-dark text-right">Bolsas Toston</label>
									<div class="col-sm-8">
										<input @keyup.enter="btnFinalizarEmbarque()" type="number" step="1" class="form-control" v-model="bolsasToston" required="">
									</div>
								</div>
							</div>
							<div class="col-sm-12 d-flex justify-content-center">
								<button type="submit" class="btn btn-info mb-2" @click="btnFinalizarEmbarque()"><i class="zmdi zmdi-save"></i>&nbsp; Finalizar</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

</section>