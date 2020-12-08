<?php 
	$datos=explode("/", $_GET['views']);

	if($_SESSION['tipo']==1){ ?>
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
				</div>
                <hr>
				<div class="row mt-1">
					<div class="col-sm-12">
						<table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm text-center" >
							<thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">ID</th>                                    
                                    <th class="text-center">Nombre</th>
									<th class="text-center">Genero</th>
									<th class="text-center">Nombre de usuario</th>
									<th class="text-center">Privilegios</th>
                                    <th class="text-center">Acciones</th>
                                </tr>    
                            </thead>
                            <tbody class="table" id="tablasUsuarios">
                                <tr v-for="list of lista">
                                    <td class="text-uppercase">{{list.id}}</td>
                                    <td class="text-uppercase">{{list.nombre}}</td>
									<td class="text-uppercase">{{list.genero}}</td>
									<td class="text-uppercase">{{list.user}}</td>
									<td v-if="list.tipo==1">Administrador</td>
									<td v-else>Capturista</td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.genero, list.user, list.tipo, <?php echo $_SESSION['id_user'];?>)"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Actualizar</button>
                                            <button class="btn btn-secondary btn-sm" title="Eliminar" @click="btnContras(list.id)"><i class="zmdi zmdi-lock"></i>&nbsp;Rest. Cont...</button>    
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

<?php }elseif($datos[1]){?>

	<section class="container-fluid d-flex justify-content-center mt-4 mb-4">
		<div class="row">
			<div class="col-sm-12">
				<h1 class="text-condensedLight"><i class="zmdi zmdi-account-o"></i> &nbsp;Usuario <a class="h4">Capturista</a></h1> 
			</div>
		</div>
	</section>

	<div class="container-fuit" id="usuarios">
		<div class="col-sm-12">
			<div class="row mt-1">
				<div class="col-sm-12">
					<table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm text-center" >
						<thead>
							<tr class="bg-dark text-light">
								<th class="text-center">ID</th>                                    
								<th class="text-center">Nombre</th>
								<th class="text-center">Genero</th>
								<th class="text-center">Nombre de usuario</th>
								<th class="text-center">Privilegios</th>
								<th class="text-center">Acciones</th>
							</tr>    
						</thead>
						<tbody class="table" id="tablasUsuarios">
							<tr v-for="list of listaCapturista" v-if="list.id==<?php echo $_SESSION['id_user'];?>">
								<td class="text-uppercase">{{list.id}}</td>
								<td class="text-uppercase">{{list.nombre}}</td>
								<td class="text-uppercase">{{list.genero}}</td>
								<td class="text-uppercase">{{list.user}}</td>
								<td v-if="list.tipo==1">Administrador</td>
								<td v-else>Capturista</td>
								<td>
									<div class="btn-group" role="group">
										<button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(list.id, list.nombre, list.genero, list.user, list.tipo, <?php echo $_SESSION['id_user'];?>)"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Actualizar</button>
										<button class="btn btn-secondary btn-sm" title="Eliminar" @click="btnContras(list.id)"><i class="zmdi zmdi-lock"></i>&nbsp;Rest. Cont...</button>
									</div>
								</td>
							</tr>
						</tbody>
					</table>                
				</div>
			</div>
		</div>
	</div>

<?php }else{ ?>
	<div class="container mt-5">
		<h1 class="text-center">Página no encontrada</h1>
		<p class="text-center">No cuneta con los permisos para ver el cotenido de la pagina que busca</p>
		<div class="d-flex justify-content-center">
			<img src="<?php echo SERVERURL; ?>vistas/assets/icons/banana_error.png" width="300" >
		</div>
	</div>
<?php } ?>