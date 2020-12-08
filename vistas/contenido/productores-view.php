		<section class="container-fluid d-flex justify-content-center mt-4 mb-4">
			<div class="row">
				<div class="col-sm-12">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-account-o"></i> &nbsp; Productores</h1>
				</div>
			</div>
		</section>

		<div class="container-fuit" id="productores">
			<div class="col-sm-12">
				<div class="container-fluid row">
					<div class="col-sm-3">
                    <button @click="formularioRegistro" id="registroBtn" class="btn btn-info" title="Nuevo"><i class="zmdi zmdi-accounts-add"></i> &nbsp; Registrar</button>
					</div>
                    <div class="col-sm-6">
                        <p class="form-inline">Buscar: &nbsp; <input class="form-control col-sm-10" id="filtro" type="text" placeholder="Buscar.." autofocus></p>
                    </div>
					<div class="col-sm-3 text-right">
						<h5>Registrados: <span class="badge badge-success">{{totalRegistrados}}</span></h5>
					</div>
                </div>
                
                <!--Inicia resgitrar y actualizar -->
                <div class="container-fluid mb-1 card mb-4 p-3" id="registro" style="display: none;">
					<div class="row">
						<div class="col-sm-6">
							<div class="form-group row text-white">
								<label class="col-sm-3 col-form-label text-dark text-right">Nombre</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" id="NombreTrabajador" name="nombre-reg-trabajador" v-model="nombre">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">Apellido Paterno</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" id="apellidoPaterno" name="app-reg-trabajador" v-model="apPat">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">Apellido Materno</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" id="apellidoMaterno" name="apm-reg-trabajador" v-model="apMat">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">Edad</label>
								<div class="col-sm-6">
									<input type="number" class="form-control" v-model="edad">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">Telefono</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" maxlength="10" v-model="telefono">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">Dirección</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" v-model="direccion" name="dir-reg-trabajador">
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label text-dark text-right">No. Cuenta</label>
								<div class="col-sm-6">
									<input type="text" class="form-control" maxlength="16" v-model="cuenta" name="cuenta-reg-trabajador">
								</div>
							</div>
							
							<div class="col-sm-12 row d-flex justify-content-center">
								<button id="salvar" class="btn btn-sm btn-success" @click="btnRegistro"><i class="zmdi zmdi-save"></i>&nbsp;Guardar</button>
								&nbsp;
								<button id="modifi" style="display: none;" @click="actualizarDatos(id, nombre, apPat, apMat, edad, telefono, direccion, cuenta,  foto)" class="btn btn-sm btn-success"><i class="zmdi zmdi-save"></i>&nbsp;Modificar</button>
								&nbsp;
								<a class="btn btn-sm btn-danger text-white" @click="btnCancelarRegistro()"><i class="zmdi zmdi-close-circle-o"></i>&nbsp;Cancelar</a>
							</div>
						</div>
						<div class="col-sm-4 text-center text-white">
							<div id="my_photo_booth">
								<div id="my_camera" style="max-width:100%;min-width:100%;height:100%;"></div>
								<div id="pre_take_buttons">
									<a class="btn btn-sm btn-info" @click="save_photo()"><i class="zmdi zmdi-camera"></i>&nbsp;Capturar</a>
								</div>
							</div>
							<div id="results" class="col-sm-6 mt-2" style="display:block"></div>
						</div>
					</div>
				</div>
                 <!--Fin  -->

				<div class="row mt-1" id="tablas_trab">
					<div class="col-sm-12">
						<table id="" class="table table-striped table-bordered table-hover table-condensed table-sm" >
							<thead>
                                <tr class="bg-dark text-light">
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Edad</th>
                                    <th>Telefono</th>
                                    <th>Direccion</th>
                                    <th>No. Cuenta</th>
                                    <th>Acciones</th>
                                </tr>    
                            </thead>
                            <tbody class="table" id="tablass">
                                <tr v-for="list in lista">
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}} {{list.Ap_p}} {{list.Ap_m}}</td>
                                    <td>{{list.edad}}</td>
                                    <td>{{list.telefono}}</td>
                                    <td>{{list.direccion}}</td>
                                    <td>{{list.no_cuenta}}</td>
                                    <td class="text-center">
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-info btn-sm" title="Ver" @click="btnVer(list.id, list.nombre, list.Ap_p, list.Ap_m, list.edad, list.telefono, list.direccion, list.no_cuenta, list.foto)"><i class="zmdi zmdi-eye"></i></button>
                                            <button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.Ap_p, list.Ap_m, list.edad, list.telefono, list.direccion, list.no_cuenta, list.foto)"><i class="zmdi zmdi-refresh-sync"></i></button>
        								</div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>                
                    </div>
                </div>
			</div>
		</div>