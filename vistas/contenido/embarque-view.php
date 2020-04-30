	<div id="embarques">
		<section class="container-fluid mt-2 mb-2">
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
		
		<!--Objetos de la BD-->
		<?php
			$hoy = date("Y-m-d");
		?>

		<section class="container col-sm-12 mb-5 d-flex justify-content-center p-2" v-if="embActual != ''">
			<div class="form-inline" v-for="dat of datosEmbarque">
				<div class="form-group">
					<label>No. Bolsas</label>
					<input type="text" disabled readonly class="form-control mx-sm-3 form-control-plaintext pl-3" v-model="dat.cant_bolsas_embarque">
				</div>
				<div class="form-group">
					<label>Día</label>
					<input type="text" disabled readonly class="form-control mx-sm-3 form-control-plaintext pl-3" v-model="fecha_dia">
				</div>
			</div>
		</section>
		<div class="container" v-if="embActual != ''">
			<ul class="nav nav-pills mb-3 justify-content-center" id="pills-tab" role="tablist">
				<li class="nav-item">
					<a class="nav-link active" id="pills-proveedores-tab" data-toggle="pill" href="#pills-proveedores" role="tab" aria-controls="pills-proveedores" aria-selected="true">REGISTRO DE FRUTA</a>
				</li>
				<li class="nav-item">
					<a class="nav-link" id="pills-trabajadores-tab" data-toggle="pill" href="#pills-trabajadores" role="tab" aria-controls="pills-trabajadores" aria-selected="false">TRABAJADORES</a>
				</li>
				<li class="nav-item">
				    <a class="nav-link" id="pills-contact-tab" data-toggle="pill" href="#pills-lista" role="tab" aria-controls="pills-lista" aria-selected="false">LISTA DE PELADORES</a>
				</li>
				<li class="nav-item">
				    <a class="nav-link" id="pills-finalizar-tab" data-toggle="pill" href="#pills-finalizar" role="tab" aria-controls="pills-finalizar" aria-selected="false">FINALIZAR EMBARQUE</a>
				</li>
			</ul>
				
			<div class="tab-content" id="pills-tabContent">
				
				<!--Formulario Ingreso de fruta al embarque-->
				<div class="tab-pane fade show active" id="pills-proveedores" role="tabpanel" aria-labelledby="pills-proveedores-tab">
					<div class="row">
						<div class="col-sm-12">
							<!--div class="col-sm-12 panel-tittle bg-primary text-center tittles">
								Ingreso de Fruta
							</div-->
							<div class="row container mb-2 alert-secondary">
								<div class="col-sm-12 m-1">
									<!--Datos de la fruta-->
									<h3 class="text-center text-white tittles mt-2 bg-primary p-2">Peso de Fruta</h3>
									<div class="col-sm-12 form-inline mb-3 ">
										<div class="col-sm-10 form-group text-center">
											<label class="col-sm-4 col-md-4 text-right text-dark">Productores</label>
											<select class="custom-select col-sm-5 col-md-3" v-model="idProd">
												<option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
												{{lp.id}} - {{lp.nombre}} {{lp.Ap_p}}</option>
											</select>&nbsp;
											<input type="number" class="form-control col-sm-5 col-md-3" placeholder="Kg´s"  v-model="peso" autofocus="">&nbsp;
											<button class="btn btn-sm btn-info" @click="pesoFruta(idProd, peso)"><i class="zmdi zmdi-camera text-white"></i>&nbsp;Foto</button>
										</div>
										<div class="col-sm-2 text-right">
											&nbsp;
											<button class="btn btn-sm btn-danger"><i class="zmdi zmdi-file text-white"></i>&nbsp;Reportes PDF</button>
										</div>
									</div>
									<div class="col-sm-12 form-inline">
										<div class="col-sm-6 col-md-3 mb-1">
											<div class="card text-center">
												<img src="<?php echo SERVERURL; ?>vistas/assets/img/fondoLogin.jpg" class="card-img-top" alt="">
												<div class="card-body">
													<p class="card-text">250 kg</p>
													<button class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
												</div>
											</div>
										</div>
										<div class="col-sm-6 col-md-3 mb-1">
											<div class="card text-center">
												<img src="<?php echo SERVERURL; ?>vistas/assets/img/fondoLogin.jpg" class="card-img-top" alt="">
												<div class="card-body">
													<p class="card-text">250 kg</p>
													<button class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
												</div>
											</div>
										</div>
										<div class="col-sm-6 col-md-3 mb-1">
											<div class="card text-center">
												<img src="<?php echo SERVERURL; ?>vistas/assets/img/fondoLogin.jpg" class="card-img-top" alt="">
												<div class="card-body">
													<p class="card-text">250 kg</p>
													<button class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
												</div>
											</div>
										</div>
										<div class="col-sm-6 col-md-3 mb-1">
											<div class="card text-center">
												<img src="<?php echo SERVERURL; ?>vistas/assets/img/fondoLogin.jpg" class="card-img-top" alt="">
												<div class="card-body">
													<p class="card-text">220 kg</p>
													<button class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
												</div>
											</div>
										</div>
										<div class="col-sm-6 col-md-3 mb-1">
											<div class="card text-center">
												<img src="<?php echo SERVERURL; ?>vistas/assets/img/fondoLogin.jpg" class="card-img-top" alt="">
												<div class="card-body">
													<p class="card-text">160 kg</p>
													<button class="btn btn-sm btn-outline-danger"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
												</div>
											</div>
										</div>
									</div>
									<div class="col-sm-12 d-flex justify-content-center mt-1">
										<button type="submit" class="btn btn-info mb-2" @click="btnRegFruta()"><i class="zmdi zmdi-save"></i>&nbsp; Registrar</button>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!--Lista de trabajadores, para registrar a los trabajadores del día-->
				<div class="tab-pane fade" id="pills-trabajadores" role="tabpanel" aria-labelledby="pills-trabajadores-tab">
					<div class="row">
						<div class="col-sm-12">
							<!--================================================
							=            Condigo para Filtar Tablas            =
							=================================================-->
							
							<div class="row col-sm-12 mt-1 p-2">
								<div class="col-sm-6">
									<p class="form-inline">Buscar: &nbsp; 
										<input class="form-control col-sm-8 col-md-4" type="number" placeholder="Buscar ID..." autofocus="" v-model="filtro">
									</p>
								</div>
								<div class="col-sm-6 d-flex justify-content-end p-1">
									<button class="btn btn-dark"><i class="zmdi zmdi-save"></i></button>
								</div>
							</div>
							
							<!--====  End of Condigo para Filtar Tablas  ====-->
							
							<div class="row container d-flex justify-content-center mt-3">
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
											<tr v-for="listaD in search">
												<td class="text-center">{{listaD.id}}</td>
												<td class="text-left">{{listaD.nombre}} {{listaD.Ap_p}} {{listaD.Ap_m}}</td>
												<td class="text-left">
													<p>Bolsero</p>
												</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnAsistencia(listaD.id, listaD.Tipo)">
														<i class="zmdi zmdi-check"></i>&nbsp;Asistencia
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

				<!--Lista de trabajadores del día, donde se agregaran bolsas a los trabajadores del día-->
				<div class="tab-pane fade" id="pills-lista" role="tabpanel" aria-labelledby="pills-lista-tab">
					<div class="row">
						
						<div class="col-sm-12">
							<!--================================================
							=            Condigo para Filtar Tablas            =
							=================================================-->
							
							<div class="row col-sm-12 p-2">
								<div class="col-sm-12 col-md-6">
									<p class="form-inline">Buscar: &nbsp; 
										<input class="form-control col-sm-8 col-md-4" id="filtro" type="number" placeholder="Buscar ID..." autofocus v-model="filtro_2">
									</p>
								</div>
								<div class="col-sm-12 col-md-6 d-flex justify-content-md-end">
									<button class="btn btn-outline-danger btn-sm" @click="finalizarDia()"><i class="zmdi zmdi-calendar-alt"></i>&nbsp;Finalizar Día</button>&nbsp;
									<button class="btn btn-outline-dark btn-sm" @click=""><i class="zmdi zmdi-eye"></i>&nbsp;Ver Tablero</button>
								</div>
							</div>
							
							<!--====  End of Condigo para Filtar Tablas  ====-->

							<div class="row container d-block justify-content-center mt-3">
								<div class="row container d-block justify-content-center mt-3">
									<div class="col-sm-12 table-responsive-sm">
										<table class="text-dark table table-hover table-sm">
											<thead class="thead-dark">
												<tr>
													<th class="text-center">ID</th>
													<th class="text-center">Nombre</th>
													<th class="text-center">No. Bolsas</th>
													<th class="text-center">Bolsero</th>
													<th class="text-center">Productor</th>
													<th class="text-center">Acciones</th>
												</tr>
											</thead>
											<tbody class="table" id="tablass">
												<tr v-for="listaP in search2">
													<td class="text-center">{{listaP.id}}</td>
													<td class="text-left">{{listaP.nombre}} {{listaP.Ap_p}} {{listaP.Ap_m}}</td>
													<td class="text-center">{{listaP.cantidad_bolsas_pe}}</td>
													<td class="text-center">
														<select class="form-control" v-model="id_bolsero">
															<option v-for="bolseros in bolserosAsistentes">
																{{bolseros.id_bolsero}}
															</option>
														</select>
													</td>
													<td class="text-center">
														<select class="form-control" v-model="id_productor">
															<option v-for="fruta in listaFruta" >
																{{fruta.id_fruta}}
															</option>
														</select>
													</td>
													<td class="text-center">
														<button class="btn btn-outline-success btn-sm"  @click="btnAddBolsa(listaAs.id_p, listaAs.nombre)">
															<i class="zmdi zmdi-plus-circle"></i>&nbsp;Añadir Bolsa
														</button>&nbsp;
														<button class="btn btn-outline-primary btn-sm"  @click="btnAsignarTrabajo(listaAs.id_p)">
															<i class="zmdi zmdi-case"></i>&nbsp;Otro Trabajo
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
					<div class="row">
						<div class="col-sm-12 mb-5">
							<div class="col-sm-12 panel-tittle bg-primary text-center tittles">
								Finalizar Embarque
							</div>
							<div class="col-sm-12 mt-3">
								<!--Datos de la fruta-->
									<div class="form-group row">
										<label for="fecha" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>
										<div class="col-sm-4">
											<input type="date" class="form-control" v-model="fecha_fin" required="">
										</div>
									</div>
									<div class="form-group row">
										<label for="contenedor" class="col-sm-4 col-form-label text-dark text-right">No. Contenedor</label>
										<div class="col-sm-4">
											<input type="text" class="form-control" id="contenedor" v-model="contenedor" required="">
										</div>
									</div>
									<div class="form-group row">
										<label for="sello" class="col-sm-4 col-form-label text-dark text-right">Sello</label>
										<div class="col-sm-4">
											<input type="text" class="form-control" id="sello" v-model="sello" required="">
										</div>
									</div>
									<div class="form-group row">
										<label for="temperatura" class="col-sm-4 col-form-label text-dark text-right">Temperatura</label>
										<div class="col-sm-4">
											<input type="number" class="form-control" id="temperatura" v-model="temperatura" required="">
										</div>
									</div>
									<div class="form-group row">
										<label for="matricula" class="col-sm-4 col-form-label text-dark text-right">Matricula (Vehiculo)</label>
										<div class="col-sm-4">
											<input type="text" class="form-control" v-model="matricula" required="">
										</div>
									</div>
									<div class="form-group row">
										<label for="conductor" class="col-sm-4 col-form-label text-dark text-right">Nombre Conductor</label>
										<div class="col-sm-4">
											<input type="text" class="form-control" v-model="conductor" required="">
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
	</div>

</section>