<?php if($_SESSION['tipo']==1){ ?>

	<div id="actu">
		<section class="container-fluid mt-2 mb-1">
			<div class="row">
				<div class="col-sm-12 col-md-4 text-center">
					<h1 class="text-condensedLight"><i class="zmdi zmdi-search-in-file"></i> &nbsp; Datos Embarque {{embActual}}</h1>
				</div>
				<div class="col-sm-6 col-md-4 mt-2">
					<div class="form-inline justify-content-center">
						<div class="form-group">
							<!--Lista de embarques actuales-->
							<label>No. Emb.</label>
							<select class="custom-select custom-select-sm mx-sm-3" v-model="selected">
								<option v-if="listaEmbarques == ''">Sin datos...</option>
								<option v-for="l of listaEmbarqueActivo" :key="l.id">{{l.id}}</option>
								<option v-for="lista of listaEmbarques" :key="lista.id">{{lista.id}}</option>
							</select>
						</div>
						<!--Cargar los datos de embarque seleccionado-->
						<button @click="btnCargarDatos" class="btn btn-warning btn-sm text-white"><i class="zmdi zmdi-search-in-page"></i>&nbsp;Crargar..</button>
					</div>
				</div>
			</div>
		</section>
		<!-- MENU DE OPCIONES Y CONTENIDOS -->
		<section >
			<div class="container-fluid" v-if="embActual != ''">
				<ul class="nav nav-pills mb-3 justify-content-center" id="pills-tab" role="tablist">
					<li class="nav-item">
						<a class="nav-link active" id="pills-productores-tab" data-toggle="pill" href="#pills-productores" role="tab" aria-controls="pills-productores" aria-selected="true">PRODUCTORES</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-planilla-tab" data-toggle="pill" href="#pills-planilla" role="tab" aria-controls="pills-planilla" aria-selected="false">PLANILLA TOSTON</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-bolseros-tab" data-toggle="pill" href="#pills-bolseros" role="tab" aria-controls="pills-bolseros" aria-selected="false">BOLSEROS</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-gastos-tab" data-toggle="pill" href="#pills-gastos" role="tab" aria-controls="pills-gastos" aria-selected="false">GASTOS</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-dolares-tab" data-toggle="pill" href="#pills-dolares" role="tab" aria-controls="pills-dolares" aria-selected="true">DOLARES</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-pesos-tab" data-toggle="pill" href="#pills-pesos" role="tab" aria-controls="pills-pesos" aria-selected="false">PESOS</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-bolsas-tab" data-toggle="pill" href="#pills-bolsas" role="tab" aria-controls="pills-bolsas" aria-selected="false">BOLSAS</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" id="pills-resumen-tab" data-toggle="pill" href="#pills-resumen" role="tab" aria-controls="pills-resumen" aria-selected="false">RESUMEN</a>
					</li>
				</ul>

				<div class="container-fluid tab-content " id="pills-tabContent">
					<!--TABLA DE PRODUCTORES-->
					<div class="tab-pane fade show active" id="pills-productores" role="tabpanel" aria-labelledby="pills-productores-tab">
						<div class="row container-fluid d-block justify-content-center mt-3">
							<div class="row container-fluid d-block justify-content-center mt-3">
								<div class="col-sm-12 table-responsive-sm">
									<table class="text-dark table table-hover table-sm table-bordered">
										<thead class="thead-dark">
											<tr>
												<th class="text-center">Productor</th>
												<th class="text-center">Cantidad</th>
												<th class="text-center">Precio</th>
												<th class="text-center">Total</th>
												<th class="text-center">Fungicida</th>
												<th class="text-center">Fertilizante</th>
												<th class="text-center">Prestamo</th>
												<th class="text-center">Total</th>
												<th class="text-center">A. Fungicida</th>
												<th class="text-center">A. Fertilizante</th>
												<th class="text-center">A. Prestamo</th>
												<th class="text-center">A Pagar</th>
												<th class="text-center">S. Fungicida</th>
												<th class="text-center">S. Fertilizante</th>
												<th class="text-center">S. Préstamo</th>
												<th class="text-center"></th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="lista of productores">
												<td class="text-left">{{lista.nombre}}</td>
												<td class="text-right">{{lista.peso}}</td>
												<td class="text-right">{{lista.compra}}</td>
												<td class="text-right">{{lista.total1}}</td>
												<td class="text-right">{{lista.fungicida}}</td>
												<td class="text-right">{{lista.fertilizante}}</td>
												<td class="text-right">{{lista.prestamo}}</td>
												<td class="text-right">{{lista.total2}}</td>
												<td class="text-right">{{lista.abono_fun}}</td>
												<td class="text-right">{{lista.abono_fer}}</td>
												<td class="text-right">{{lista.abono_prestamo}}</td>
												<td class="text-right">{{lista.aPagar}}</td>
												<td class="text-right">{{lista.fun}}</td>
												<td class="text-right">{{lista.fer}}</td>
												<td class="text-right">{{lista.pres}}</td>

												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnActualizar(lista.idF, lista.idPres, lista.peso, lista.compra, lista.fungicida, lista.fertilizante, lista.prestamo, lista.abono_fun, lista.abono_fer, lista.abono_prestamo, lista.noPFun, lista.noPFer, lista.noPPre)">
														<i class="zmdi zmdi-refresh-sync"></i>
													</button>
												</td>
											</tr>

											<tr v-for="lista of totalesProd">
												<td class="text-center font-weight-bold"> Total</td>
												<td class="text-right font-weight-bold">{{lista.peso}}</td>
												<td class="text-right font-weight-bold">{{lista.compra}}</td>
												<td class="text-right font-weight-bold">{{lista.total1}}</td>
												<td class="text-right font-weight-bold">{{lista.fungicida}}</td>
												<td class="text-right font-weight-bold">{{lista.fertilizante}}</td>
												<td class="text-right font-weight-bold">{{lista.prestamo}}</td>
												<td class="text-right font-weight-bold">{{lista.total2}}</td>
												<td class="text-right font-weight-bold">{{lista.abono_fun}}</td>
												<td class="text-right font-weight-bold">{{lista.abono_fer}}</td>
												<td class="text-right font-weight-bold">{{lista.abono_prestamo}}</td>
												<td class="text-right font-weight-bold">{{lista.aPagar}}</td>
												<td class="text-right font-weight-bold">{{lista.fun}}</td>
												<td class="text-right font-weight-bold">{{lista.fer}}</td>
												<td class="text-right font-weight-bold">{{lista.pres}}</td>
											</tr>

										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>

					<!--TABLA DE PLANILLA TOSTON-->
					<div class="tab-pane fade" id="pills-planilla" role="tabpanel" aria-labelledby="pills-planilla-tab">
						<div class="row container-fluid d-block justify-content-center mt-3">
							<div class="row container-fluid d-block justify-content-center mt-3">
								<div class="col-sm-12">
									<div class="form-inline">
										<!--Lista de embarques actuales-->
										<label>Trabajador&nbsp;&nbsp;</label>
										<select  class="custom-select  col-sm-5" name="selec" v-model="selec">
											<option v-for="lp of listaTrabT" :key="lp.id" v-bind:value="lp.id">
											{{lp.id}} - {{lp.nombre}}  {{lp.ap_p}}</option>
										</select>
										<!--Cargar los datos de embarque seleccionado-->
										<button @click="btnRegToston" class="btn btn-primary col-sm-2"><i class="zmdi zmdi-account-add"></i>&nbsp;&nbsp; Agregar trab.</button>
									</div>
								</div><br>
								<div class="col-sm-12 table-responsive-sm">
									<table class="text-dark table table-hover table-sm table-bordered">
										<thead class="thead-dark">
											<tr>
												<th class="text-center">ID</th>
												<th class="text-center">Nombre</th>
												<th class="text-center">Día A</th>
												<th class="text-center">Día B</th>
												<th class="text-center">Día C</th>
												<th class="text-center">Día D</th>
												<th class="text-center">Día E</th>
												<th class="text-center">Total</th>
												<th class="text-center">Acciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="lista of listaToston">
												<td class="text-center">{{lista.id}}</td>
												<td class="text-left">{{lista.nombre}}</td>
												<td class="text-right">$ {{lista.diaUno}}</td>
												<td class="text-right">$ {{lista.diaDos}}</td>
												<td class="text-right">$ {{lista.diaTres}}</td>
												<td class="text-right">$ {{lista.diaCuatro}}</td>
												<td class="text-right">$ {{lista.diaCinco}}</td>
												<td class="text-right">$ {{lista.pago}}</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnToston(lista.id,lista.diaUno,lista.diaDos, lista.diaTres, lista.diaCuatro, lista.diaCinco)">
														<i class="zmdi zmdi-refresh-sync"></i>&nbsp;Modificar
													</button>
													<button class="btn btn-outline-danger btn-sm"  @click="btnEliminarToston( lista.id)">
														<i class="zmdi zmdi-delete"></i>&nbsp;Eliminar
													</button>
												</td>
											</tr>
											<tr>
												<td colspan="7" class="text-right font-weight-bold">TOTAL</td>
												<td  class="text-right font-weight-bold" v-for="lista of listaTotalT">$ {{lista.total}}</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>

					<!--TABLA DE BOLSEROS-->
					<div class="tab-pane fade" id="pills-bolseros" role="tabpanel" aria-labelledby="pills-bolseros-tab">
						<div class="row container-fluid d-block justify-content-center mt-3">
							<div class="row container-fluid d-block justify-content-center mt-3">
								<div class="col-sm-12">
									<div class="form-inline">
										
										<label>Trabajador&nbsp;&nbsp;</label>
										<select  class="custom-select  col-sm-5" name="selec" v-model="selec">
											<option v-for="lp of listaBolT" :key="lp.id" v-bind:value="lp.id">
											{{lp.id}} - {{lp.nombre}}  {{lp.Ap_p}}</option>
										</select>
										

										<button @click="btnRegBolsero" class="btn btn-primary col-sm-2"><i class="zmdi zmdi-account-add"></i>&nbsp;&nbsp; Agregar trab.</button>
									</div>
								</div><br> 
								<div class="col-sm-12 table-responsive-sm">
									<table class="text-dark table table-hover table-sm table-bordered">
										<thead class="thead-dark">
											<tr>
												<th class="text-center">ID</th>
												<th class="text-center">Nombre</th>
												<th class="text-center">Dia A</th>
												<th class="text-center">Dia B</th>
												<th class="text-center">Dia C</th>
												<th class="text-center">Dia D</th>
												<th class="text-center">Dia E</th>
												<th class="text-center">Pago total</th>
												<th class="text-center">Acciones</th>
											</tr>
										</thead>
										<tbody class="table" id="tablass">
											<tr v-for="lista of listaBo">
												<td class="text-center">{{lista.id}}</td>
												<td class="text-left">{{lista.nombre}}</td>
												<td class="text-right">$ {{lista.diaUno}}</td>
												<td class="text-right">$ {{lista.diaDos}}</td>
												<td class="text-right">$ {{lista.diaTres}}</td>
												<td class="text-right">$ {{lista.diaCuatro}}</td>
												<td class="text-right">$ {{lista.diaCinco}}</td>
												<td class="text-right">$ {{lista.pago}}</td>
												<td class="text-center">
													<button class="btn btn-outline-success btn-sm" @click="btnUpdateB(lista.id, lista.diaUno,lista.diaDos, lista.diaTres, lista.diaCuatro, lista.diaCinco)" >
														<i class="zmdi zmdi-refresh-sync"></i>&nbsp;Modificar
													</button>
													<button class="btn btn-outline-danger btn-sm"  @click="btnDeleteBolsero(lista.id)">
														<i class="zmdi zmdi-delete"></i>&nbsp;Eliminar
													</button>
												</td>
											</tr>
											<tr>
												<td colspan="7" class="text-right font-weight-bold">TOTAL</td>
												<td  class="text-right font-weight-bold" v-for="lista of listaToB">$ {{lista.total}}</td>
											</tr>
										</tbody>
									</table>

								</div>
								
							</div>
						</div> 
					</div>

					<!-- TABLA DE GASTOS -->
					<div class="tab-pane fade" id="pills-gastos" role="tabpanel" aria-labelledby="pills-gastos-tab">
						<section class="container-fluid alert-info p-2">
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
										<button @click="btnResgGasto()" class="btn btn-primary"><i class="zmdi zmdi-save"></i>&nbsp;Registrar</button>
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
					
					<div class="tab-pane fade" id="pills-dolares" role="tabpanel" aria-labelledby="pills-dolares-tab">
						<div class="row">
							<div class="form-inline col-sm-4">
								<label class="form-control-label col-sm-12 text-center">Concepto</label>
								<input @keyup.enter="btnRegistro(concepto,ingreso, egreso)" type="text" class="form-inline form-control col-sm-12" id="concepto" v-model="concepto">
							</div>
							<div class="form-inline col-sm-6">
								<div class="form-group col-sm-6">
									<label class="form-control-label col-sm-12 text-center">Ingreso</label>
									<input @keyup.enter="btnRegistro(concepto,ingreso, egreso)" type="number"step="0.01"  class="form-inline form-control col-sm-12"  id="ingreso" v-model="ingreso">
								</div>
								<div class="form-group col-sm-6">
									<label class="form-control-label col-sm-12 text-center">Egreso</label>
									<input @keyup.enter="btnRegistro(concepto,ingreso, egreso)" type="number" step="0.01" class="form-inline form-control col-sm-12" name="egreso" id="egreso" v-model="egreso">
								</div>
							</div>
							<div v-if="egreso>0" class="form-inline col-sm-2">
								<label class="form-control-label col-sm-12 text-center">Taza de Camb.</label>
								<input @keyup.enter="btnRegistro(concepto,ingreso, egreso)" type="number" step="0.01" class="form-inline form-control col-sm-12" name="taza" id="taza" v-model="taza">
							</div>
						</div>
						<div class="text-center col-sm-12 mt-2 p-1">
							<button @click="btnRegistro(concepto,ingreso, egreso)" class="btn btn-sm btn-success col-sm-2"><i class="zmdi zmdi-save"></i>&nbsp;Registrar en Dolares</button>
						</div>
						<hr>
						<div class="mt-2 col-sm-12 p-2 mb-2 bg-success text-center tittles text-white">CUENTA EN DOLARES</div>
						<table class="table table-bordered table-sm">
							<thead>
								<tr class="bg-dark text-light">
									<th class="text-center">Concepto</th>
									<th class="text-center">Ingreso</th>
									<th class="text-center">Egreso</th>
									<th class="text-center">Saldo</th>
									<th class="text-center"></th>
								</tr>
							</thead>
							<tbody>
								<tr class="tabla text-center" v-for="list of listaDolares" v-if="list.mostrar>0">
									<td>{{list.concepto}}</td>
									<td>{{list.ingreso}}</td>
									<td>{{list.egreso}}</td>
									<td>{{list.saldo}}</td>
									<td>
										<button v-if="list.activo!=0" class="btn btn-sm btn-success" @click="modDolar(list.id, list.id_cuentaD, list.concepto, list.ingreso, list.egreso, list.saldo, list.taza_cambio)">
											<i class="zmdi zmdi-refresh-sync"></i>
										</button>
										<button v-if="list.activo!=0" class="btn btn-sm btn-danger" @click="deleteDolar(list.id, list.id_cuentaD, list.ingreso, list.egreso, list.taza_cambio, list.saldo)">
											<i class="zmdi zmdi-delete"></i>
										</button>
									</td>
								</tr>
								<tr class="tabla text-center" v-for="list of listaT">
									<td class="font-weight-bold">Totales</td>
									<td class="font-weight-bold">{{list.ingreso}}</td>
									<td class="font-weight-bold">{{list.egreso}}</td>
									<td class="font-weight-bold">{{list.saldo}}</td>
									<td></td>
								</tr>
							</tbody>
						</table>
						<br>
					</div>
					
					<div class="tab-pane fade" id="pills-pesos" role="tabpanel" aria-labelledby="pills-pesos-tab">
						<div class="col-sm-12">
							<div class="row">
								<div class="form-inline col-sm-4">
									<label class="form-control-label col-sm-12 text-center">Concepto</label>
									<input @keyup.enter="btnRegPesos(conceptoP, ingresoP, egresoP)" type="text" class="form-inline form-control col-sm-12" v-model="conceptoP">
								</div>
								<div class="form-inline col-sm-6">
									<div class="form-group col-sm-6">
										<label class="form-control-label col-sm-12 text-center">Ingreso</label>
										<input @keyup.enter="btnRegPesos(conceptoP, ingresoP, egresoP)" type="number"step="0.01"  class="form-inline form-control col-sm-12" v-model="ingresoP">
									</div>
									<div class="form-group col-sm-6">
										<label class="form-control-label col-sm-12 text-center">Egreso</label>
										<input @keyup.enter="btnRegPesos(conceptoP, ingresoP, egresoP)" type="number" step="0.01" class="form-inline form-control col-sm-12" v-model="egresoP">
									</div>
								</div>
								<div class="text-center col-sm-12 mt-2 p-1">
									<button @click="btnRegPesos(conceptoP, ingresoP, egresoP)" class="btn btn-sm btn-primary"><i class="zmdi zmdi-save"></i>&nbsp;Registrar en Pesos</button>
								</div>
							</div>
						</div>
						<hr>
						<div class="col-sm-12 p-2 mb-2 bg-info text-center tittles text-white">CUENTA EN PESOS MXN</div>
						<table class="table table-bordered table-sm">
							<thead>
								<tr class="bg-dark text-light">

									<th class="text-center">Concepto</th>
									<th class="text-center">Ingreso</th>
									<th class="text-center">Egreso</th>
									<th class="text-center">Saldo</th>
									<th class="text-center"></th>
								</tr>
							</thead>
							<tbody >
								<tr class="tabla text-center" v-for="lisP of listaPesos" v-if="lisP.mostrar>0">
									<td>{{lisP.concepto}}</td>
									<td>{{lisP.ingreso}}</td>
									<td>{{lisP.egreso}}</td>
									<td>{{lisP.saldo}}</td>
									<td>
										<button v-if="lisP.activo!=0" class="btn btn-sm btn-success" @click="modPesos(lisP.id, lisP.id_cuenta, lisP.concepto, lisP.ingreso, lisP.egreso, lisP.saldo)">
											<i class="zmdi zmdi-refresh-sync"></i>
										</button>
										<button v-if="lisP.activo!=0" class="btn btn-sm btn-danger" @click="deletePesos(lisP.id, lisP.id_cuenta, lisP.ingreso, lisP.egreso, lisP.saldo)">
											<i class="zmdi zmdi-delete"></i>
										</button>
									</td>
								</tr>
								<tr class="tabla text-center" v-for="list of listaTP">
									<td class="font-weight-bold">Totales</td>
									<td class="font-weight-bold">{{list.ingreso}}</td>
									<td class="font-weight-bold">{{list.egreso}}</td>
									<td class="font-weight-bold">{{list.saldo}}</td>
									<td></td>
								</tr>
							</tbody>
						</table>
					</div>

					<div class="tab-pane fade" id="pills-bolsas" role="tabpanel" aria-labelledby="pills-bolsas-tab">
						<div class="col-sm-12">
							<div class="row">
								<div class="form-inline col-sm-4">
									<label class="form-control-label col-sm-12 text-center">Concepto</label>
									<input @keyup.enter="btnRegBolsas(conceptoB, ingresoB, egresoB)" type="text" class="form-inline form-control col-sm-12" v-model="conceptoB">
								</div>
								<div class="form-inline col-sm-6">
									<div class="form-group col-sm-6">
										<!--label class="form-control-label col-sm-12 text-center">Ingreso</label-->
										<input type="hidden"step="0.01"  class="form-inline form-control col-sm-12" v-model="ingresoB">
									</div>
									<div class="form-group col-sm-6">
										<label class="form-control-label col-sm-12 text-center">Egreso</label>
										<input @keyup.enter="btnRegBolsas(conceptoB, ingresoB, egresoB)" type="number" step="0.01" class="form-inline form-control col-sm-12" v-model="egresoB">
									</div>
								</div>
								<div class="text-center col-sm-12 mt-2 p-1">
									<button @click="btnRegBolsas(conceptoB, ingresoB, egresoB)" class="btn btn-sm btn-secondary"><i class="zmdi zmdi-save"></i>&nbsp;Registrar en Bolsas</button>
								</div>
							</div>
						</div>
						<hr>
						<table class="table table-bordered table-sm">
							<thead>
								<tr class="bg-dark text-light">

									<th class="text-center">Concepto</th>
									<th class="text-center">Ingreso</th>
									<th class="text-center">Egreso</th>
									<th class="text-center">Saldo</th>
									<th class="text-center"></th>
								</tr>
							</thead>
							<tbody>
								<tr class="tabla text-center" v-for="lisB of listaBolsas" v-if="lisB.mostrar>0">

									<td>{{lisB.concepto}}</td>
									<td>{{lisB.ingreso}}</td>
									<td>{{lisB.egreso}}</td>
									<td>{{lisB.saldo}}</td>
									<td>
										<button v-if="lisB.activo!=0" class="btn btn-sm btn-success" @click="modBolsas(lisB.id, lisB.id_cuenta, lisB.concepto, lisB.ingreso, lisB.egreso, lisB.saldo)">
											<i class="zmdi zmdi-refresh-sync"></i>
										</button>
										<button v-if="lisB.activo!=0" class="btn btn-sm btn-danger" @click="deleteBolsas(lisB.id, lisB.id_cuenta, lisB.ingreso, lisB.egreso, lisB.saldo)">
											<i class="zmdi zmdi-delete"></i>
										</button>
									</td>

								</tr>
								<tr class="tabla text-center" v-for="list of listaTB">

									<td class="font-weight-bold">Totales</td>
									<td class="font-weight-bold">{{list.ingreso}}</td>
									<td class="font-weight-bold">{{list.egreso}}</td>
									<td class="font-weight-bold">{{list.saldo}}</td>
									<td></td>
								</tr>
							</tbody>
						</table>
					</div>

					<div class="tab-pane fade" id="pills-resumen" role="tabpanel" aria-labelledby="pills-resumen-tab">
						<br><br>
						<div class="container" >
							<div class="row justify-content-md-center">
								<div class="col-sm-9">
									<table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm" >
										<tbody  class="table" id="tablass" v-for="lista of listaR">
											<tr>
												<td>GASTO TOTAL EMBARQUE</td>
												<td>{{lista.gasto}}</td>
											</tr>
											<tr >
												<td>GASTO TOTAL EMBARQUE DÓLAR</td>
												<td>{{lista.gastoD}}</td>
											</tr>
											<tr >
												<td>TAZA DE CAMBIO</td>
												<td>{{lista.taza}}</td>
											</tr>
											<tr >
												<td>CANTIDAD DE BOLSAS</td>
												<td>{{lista.bolsas}}</td>
											</tr>
											<tr >
												<td>COSTO PESOS</td>
												<td>{{lista.costoP}}</td>
											</tr>
											<tr >
												<td>COSTO DÓLAR</td>
												<td>{{lista.costoD}}</td>
											</tr>
										</tbody>
									</table>
								</div>
								<div class="col-sm-12 col-md-6 d-flex justify-content-md-end">
									<!--button type="submit" class="btn btn-info mb-2" @click="btncerrarCuenta()"><i class="zmdi zmdi-save"></i>&nbsp; Cerrar cuenta</button-->
								</div>
							</div>
						</div>
					</div>

				</div>
			</div>
		</section>
	</div>

<?php }else{?>
	<div class="container mt-5">
		<h1 class="text-center">Página no encontrada</h1>
		<p class="text-center">No cuenta con los permisos para ver el contenido de la página que busca</p>
		<div class="d-flex justify-content-center">
			<img src="<?php echo SERVERURL; ?>vistas/assets/icons/banana_error.png" width="300" >
		</div>
	</div>
<?php } ?>