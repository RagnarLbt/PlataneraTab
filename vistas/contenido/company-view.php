<?php if($_SESSION['tipo']==1){ ?>
		<section class="container-fluid d-flex justify-content-center mt-4 mb-4">
			<div class="row">
				<div class="col-sm-12">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-case"></i> &nbsp;<?php echo COMPANY; ?></h1> 
				</div>
			</div>
		</section>

		<div class="container" id="empresa">
			<h5 class="text-center">Datos generales de la Empresa, puede modificar los datos y despues guardar los cambios</h5>
			<hr>
			<div class="col-sm-12 mt-1 mb-2">
				<h3>Precios y Pago</h3>
				<table class="table table-hover table-sm table-light table-bordered">
					<thead>
						<tr class="thead-dark">
							<th class="text-center" scope="col">Precio de Compra por Kg</th>
							<th class="text-center" scope="col">Pago a Peladores</th>
							<th class="text-center" scope="col">Pago a Bolseros</th>
							<th class="text-center" scope="col">Acciones</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="p in getPagos">
							<td class="text-center">$ {{p.cantidad}}</td>
							<td class="text-center">$ {{p.pago_pelador}}</td>
							<td class="text-center">$ {{p.pago_bolsero}}</td>
							<td class="text-center">
								<div class="btn-group" role="group">
									<button class="btn btn-success btn-sm" title="Modificar" @click="btnModificar(p.id_precio)"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Actualizar</button>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<hr>
			<div class="row">
				<div class="col-sm-12 mb-3">
					<h3>Gastos</h3>
					<div class="form-inline">
						<label class="form-control-label col-sm-4 text-right">
							Nuevo Tipo de Gasto
						</label>
						<input type="text" class="form-control col-sm-4" required name="gasto-reg" v-model="gastoNuevo" @keyup.enter="btnRegistroGasto()">
						&nbsp;&nbsp;
						<button @click="btnRegistroGasto()" class="btn btn-info"><i class="zmdi zmdi-save"></i>&nbsp; Guardar</button>
					</div>
				</div>
				<div class="col-sm-12 p-4 d-flex justify-content-center">
					<table class="col-sm-8 table table-hover table-sm table-bordered">
						<thead>
							<tr class="thead-dark">
								<th class="text-center" scope="col">#</th>
								<th class="text-center" scope="col">Tipo de Gasto</th>
								<th class="text-center" scope="col">Acciones</th>
							</tr>
						</thead>
						<tbody>
							<tr v-for="lis of listGastos">
								<th class="text-center">{{lis.id_gasto}}</th>
								<td class="text-left">{{lis.nombre}}</td>
								<td class="text-center">
									<div class="btn-group" role="group">
										<button class="btn btn-success btn-sm" title="Editar" @click="btnUpdate(lis.id_gasto, lis.nombre)"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Actualizar</button>    
										<!--button class="btn btn-danger btn-sm" title="Eliminar" @click="btnDelete(lis.id_gasto)"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button-->
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
<?php }else{?>

	<div class="container mt-5">
		<h1 class="text-center">Página no encontrada</h1>
		<p class="text-center">No cuneta con los permisos para ver el cotenido de la pagina que busca</p>
		<div class="d-flex justify-content-center">
			<img src="<?php echo SERVERURL; ?>vistas/assets/icons/banana_error.png" width="300" >
		</div>
	</div>

<?php } ?>