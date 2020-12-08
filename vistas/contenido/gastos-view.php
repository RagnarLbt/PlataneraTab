<?php if($_SESSION['tipo']==1){ ?>
	<div id="gastos">
		<section class="container-fluid mt-2 mb-1">
			<div class="row">
				<div class="col-sm-12 col-md-4 text-center">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-money"></i> &nbsp; Gastos del Embarque {{embActual}}</h1>
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
			</div>
		</section>
		<hr>
		<section class="container-fluid" v-if="embActual != ''">
			<div class="col-sm-12">
				<div class="row">
					<div class="form-inline col-sm-4">
						<label class="form-inline col-sm-3">Gasto</label>
						<select name="" id="" class="form-control col-sm-7" v-model="idGasto">
							<option v-for="lg of listGastos" :key="lg.id_gasto" v-bind:value="lg.id_gasto">{{lg.nombre}}
							</option>
						</select>
					</div>
					<div class="form-inline col-sm-8" v-if="idGasto != '' || idGasto != 0">
						<div class="form-group col-sm-6" v-if="idGasto == 22">
							<label class="form-inline col-sm-3">Concepto</label>
							<input @keyup.enter="btnResgGasto()" type="text" class="form-inline form-control col-sm-8" v-model="concepto">
						</div>
						<div class="form-group col-sm-6">
							<label class="form-inline col-sm-3">Cantidad</label>
							<input @keyup.enter="btnResgGasto()" type="number" step="0.01" class="form-inline form-control col-sm-7" v-model="cantidad">
						</div>
						<div class="form-group col-sm-6" v-if="idGasto == 5">
							<label class="form-inline col-sm-3">Kilos</label>
							<input @keyup.enter="btnResgGasto()" type="text" class="form-inline form-control col-sm-8" v-model="kilos_bolsas">
						</div>
					</div>
					<div class="text-center col-sm-12 mt-3">
						<button @click="btnResgGasto()" class="btn btn-outline-info"><i class="zmdi zmdi-save"></i>&nbsp;Registrar</button>
					</div>
				</div>
			</div>
		</section>
		<hr>
		<section class="container col-sm-12 mb-2" v-if="embActual != ''">
			<div class="form-inline d-flex justify-content-around" v-for="dat of datosGastos">
				<div class="">
					<div class="form-group">
						<label>Total de Gastos</label>
						<input type="text" disabled readonly class="form-control mx-sm-3 form-control-plaintext pl-3" v-model="dat.total_gastos">
					</div>
				</div>
			</div>
			<br>
			<div class="container">
				<div class="row container d-block justify-content-center mt-1">
					<div class="col-sm-12 table-responsive-sm">
						<table class="text-dark table table-hover table-sm">
							<thead class="thead-dark">
								<tr>
									<th class="text-center">Gasto</th>
									<th class="text-center">Total</th>
									<th class="text-center">Acciones</th>
								</tr>
							</thead>
							<tbody class="table">
								<tr v-for="listGas in listaGastosTipo">
									<td class="text-left">{{listGas.nombre}} <code>{{listGas.extra}}<code></td>
									<td class="text-right">$ {{listGas.cantidad}}</td>
									<td class="text-center">
										<button @click="btnModificar(listGas.id, listGas.idg, listGas.nombre, listGas.cantidad)" class="btn btn-success btn-sm"><i class="zmdi zmdi-refresh-sync"></i>&nbsp;Modificar</button>
										<button @click="btnEliminarGasto(listGas.id, listGas.idg, listGas.cantidad, listGas.nombre)" class="btn btn-danger btn-sm"><i class="zmdi zmdi-delete"></i>&nbsp;Eliminar</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</section>
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