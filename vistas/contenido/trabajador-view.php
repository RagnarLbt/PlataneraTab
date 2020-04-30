		<section class="container-fluid d-flex justify-content-center mt-4 mb-4">
			<div class="row">
				<div class="col-sm-12">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-accounts"></i> &nbsp; Tabajadores</h1>
				</div>
			</div>
		</section>

		<div class="container-fuit" id="trabajadores">
			<div class="col-sm-12">
				<div class="container-fluid row mb-1">
					<div class="col-sm-3">
						<button @click="btnRegistro" class="btn btn-info" title="Nuevo"><i class="zmdi zmdi-accounts-add"></i> &nbsp; Registrar</button>
					</div>
					 <div class="col-sm-6">
                        <p class="form-inline">Buscar: &nbsp; <input class="form-control col-sm-10" id="filtro" type="text" placeholder="Buscar..." autofocus></p>
                    </div>
					<div class="col-sm-3 text-right">
						<h5>Registrados: 
							<span class="badge badge-success">Peladores: {{totalRegistradosP}}</span>
							<span class="badge badge-success">Bolseros: {{totalRegistradosB}}</span>
						</h5>
					</div>
				</div>

				<div class="container-fluid row mb-1">
					
					<!--=====================================
					=            Tabla de peladores         =
					======================================-->
						<div class="col-sm-6">
							<h4 class="text-center col-sm-12 alert-info p-2">Peladores</h4>
							<div class="col-sm-12">
								<table id="" class="table table-striped table-bordered table-hover table-condensed table-sm">
									<thead>
		                                <tr class="bg-dark text-light">
		                                    <th>ID</th>                                    
		                                    <th>Nombre</th>
		                                    <th>Ap. Paterno</th>
		                                    <th>Ap. Materno</th>
		                                    <th>Acciones</th>
		                                </tr>    
		                            </thead>
		                            <tbody class="table" id="tablass">
		                                <tr v-for="list in listaTrabP">
		                                    <td>{{list.id}}</td>
		                                    <td>{{list.nombre}}</td>
		                                    <td>{{list.Ap_p}}</td>
		                                    <td>{{list.Ap_m}}</td>
		                                    <td>
		                                    <div class="btn-group" role="group">
		                                        <button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.Ap_p, list.Ap_m, list.Tipo)"><i class="zmdi zmdi-refresh-sync"></i></button>    
		                                        <button class="btn btn-danger btn-sm" title="Eliminar" @click="btnDelete(list.id, list.Tipo)"><i class="zmdi zmdi-delete"></i></button>
		    								</div>
		                                    </td>
		                                </tr>    
		                            </tbody>
		                        </table>                    
		                    </div>
		                </div>
					<!--====  End of Tabla de peladores  ====-->
					
					<!--=======================================
					=            Tabla de bolseros            =
					========================================-->
		            	<div class="col-sm-6">
							<h4 class="text-center col-sm-12 alert-secondary p-2">Bolseros</h4>
							<div class="col-sm-12">
								<table id="" class="table table-striped table-sm table-hover">
									<thead>
		                                <tr class="bg-dark text-light">
		                                    <th>ID</th>
		                                    <th>Nombre</th>
		                                    <th>Ap. Paterno</th>
		                                    <th>Ap. Materno</th>
		                                    <th>Acciones</th>
		                                </tr>
		                            </thead>
		                            <tbody class="table" id="tablass">
		                                <tr v-for="list of listaTrabB">                                
		                                    <td>{{list.id}}</td>
		                                    <td>{{list.nombre}}</td>
		                                    <td>{{list.Ap_p}}</td>
		                                    <td>{{list.Ap_m}}</td>
		                                    <td>
		                                    <div class="btn-group" role="group">
		                                        <button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.Ap_p, list.Ap_m, list.Tipo)"><i class="zmdi zmdi-refresh-sync"></i></button>    
		                                        <button class="btn btn-danger btn-sm" title="Eliminar" @click="btnDelete(list.id, list.Tipo)"><i class="zmdi zmdi-delete"></i></button>
		    								</div>
		                                    </td>
		                                </tr>    
		                            </tbody>
		                        </table>                    
		                    </div>
		                </div>
					
					<!--====  End of Tabla de bolseros  ====-->

	            </div>
			</div>
		</div>
	</section>