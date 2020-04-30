		<section class="container-fluid d-flex justify-content-center mt-4 mb-4">
			<div class="row">
				<div class="col-sm-12">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-account-o"></i> &nbsp;Usuarios <a class="h4">ADMINISTRADOR</a></h1> 
				</div>
			</div>
		</section>

		<div class="container-fuit" id="usuarios">
			<div class="col-sm-12">
				<div class="container-fluid row">
					<div class="col-sm-3">
						<button @click="btnRegistro()" class="btn btn-info" title="Nuevo"><i class="zmdi zmdi-accounts-add"></i> &nbsp; Registrar</button>
					</div>
                    <div class="col-sm-6">
                        <p class="form-inline">Buscar: &nbsp; <input class="form-control col-sm-10" id="filtro" type="text" placeholder="Buscar.." autofocus></p>
                    </div>
					
				</div>
                <hr>
				<div class="row mt-1">
					<div class="col-sm-12">
						<table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm" >
							<thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">ID</th>                                    
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Apellidos</th>
									<th class="text-center">Genero</th>
									<th class="text-center">Nombre de usuario</th>
									<th class="text-center">Privilegios</th>
                                    <th class="text-center">Acciones</th>
                                </tr>    
                            </thead>
                            <tbody class="table" id="tablasUsuarios">
                                <tr v-for="list of lista">
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td>{{list.apellidos}}</td>
									<td>{{list.genero}}</td>
									<td>{{list.user}}</td>
									<td>{{list.tipo}}</td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.Ap, list.genero, list.user, list.privilegio)"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Actualizar</button>    
                                            <button class="btn btn-danger btn-sm" title="Eliminar" @click="btnDelete(list.id)"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
        								</div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>                
                    </div>
                </div>
			</div>
		</div>