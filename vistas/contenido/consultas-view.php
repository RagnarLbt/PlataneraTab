<div  id="gastos">
    <section class="container-fluid d-flex justify-content-center mt-4 mb-4">
        <div class="row">
            <div class="col-sm-12">
                <h1 class="text-condensedLight"><i class="zmdi zmdi-search-replace"></i> &nbsp;Consultar </h1> 
            </div>
        </div>
    </section>
    <div class="container" >
        <ul class="nav nav-pills mb-3 justify-content-center" id="pills-tab" role="tablist">
            <li class="nav-item">
                <a class="nav-link active" id="pills-proveedores-tab" data-toggle="pill" href="#pills-embarque" role="tab" aria-controls="pills-embarque" aria-selected="true">GASTOS EMBARQUE</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="pills-trabajadores-tab" data-toggle="pill" href="#pills-productores" role="tab" aria-controls="pills-productores" aria-selected="false">CONSULTA PRODUCTORES</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="pills-trabajadores-tab" data-toggle="pill" href="#pills-trabajadores" role="tab" aria-controls="pills-trabajadores" aria-selected="false"> TRABAJADORES</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="pills-contact-tab" data-toggle="pill" href="#pills-general" role="tab" aria-controls="pills-general" aria-selected="false">CONSULTAS GENERALES</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="pills-reporte-tab" data-toggle="pill" href="#pills-reporte" role="tab" aria-controls="pills-reporte" aria-selected="false">REPORTES PDF</a>
            </li>
        </ul>
        <br>
        <div class="container-fluid tab-content " id="pills-tabContent">

            <!-- Consulta de gastos de emnarques -->
            
            <div class="tab-pane fade show active" id="pills-embarque" role="tabpanel" aria-labelledby="pills-embarque-tab">

                <div class="row">
                    <div class="col-12">
                        <div class="form-inline justify-content-center">
                            <div class="form-group">
                                <!--Lista de embarques actuales-->
                                <label>Consultar por</label>
                                <select class="custom-select custom-select-sm mx-sm-3" @click="mostrar" id="select">
                                    <option value="1">Id</option>
                                    <option value="2">Rango de fechas</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                </div>
                <br>
                <div class="row" id="idEmbarque" >
                    <div class="col-sm-12">
                        <div class="container-fluid row">
                            <div class="col-sm-12 form-inline">
                                <div class="col-sm-6 form-inline">Embarque&nbsp; 
                                    <input @keyup.enter="btnBuscarId(id, id2)" class="form-control col-sm-3"  v-model="id" type="number" min="1"  autofocus>&nbsp; a &nbsp;
                                    <input @keyup.enter="btnBuscarId(id, id2)" class="form-control col-sm-3" v-model="id2" type="number" min="0"  autofocus>&nbsp;
                                </div>
                                <div class="col-sm-6 text-left">
                                    <button type="button" @click="btnBuscarId(id, id2)" class="btn btn-warning btn-sm col-sm-3">&nbsp;Aceptar</button>
                                    <button type="button" @click="btnPDF1('#tablas', id, id2)" class="btn btn-danger btn-sm col-sm-3 ml-3"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-12 mt-4" id="idE">
                        <table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Emb.</th>  
                                    <th class="text-center">Gasto</th>  
                                    <th class="text-center">Concepto</th>
                                    <th class="text-center">Cantidad</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaId">
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td>{{list.extra}}</td>
                                    <td class="text-right">{{list.cantidad}}</td>
                                </tr>
                                <tr v-for="list of datosGastos">
                                    <td colspan="3" class="text-right  font-weight-bold">Total:</td>
                                    <td class="text-right  font-weight-bold">{{list.total_gastos}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Gastos por rango de fecha embarque-->
                <div class="row mt-2" id="idRango" style="display:none">
                    <div class="col-sm-12">
                        <div class="container-fluid row">
                            <div class="col-sm-12 form-inline">
                                <div class="col-sm-8 form-inline">Fechas de: &nbsp; 
                                    <input @keyup.enter="btnBuscarR(fecha1, fecha2)" class="form-control col-sm-4" id="fecha1" v-model="fecha1" type="date"  autofocus>&nbsp; a &nbsp;
                                    <input @keyup.enter="btnBuscarR(fecha1, fecha2)" class="form-control col-sm-4" id="fecha2" v-model="fecha2" type="date"  autofocus>&nbsp;
                                </div>
                                <div class="col-sm-4 text-left">
                                    <button type="button" @click="btnBuscarR(fecha1, fecha2)" class="btn btn-warning btn-sm col-sm-5">&nbsp;Aceptar</button>
                                    <button type="button" @click="btnPDF2(fecha1, fecha2, '#tabGastosFecha')" class="btn btn-danger btn-sm col-sm-5 ml-1"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="pdf2">
                        <div class="col-sm-12 mt-4" id="idG">
                            <table id="tabGastosFecha" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">No. Embarque</th>
                                        <th class="text-center">Fecha inicio</th>
                                        <th class="text-center">Fecha fin </th>
                                        <th class="text-center">Bolsas totales </th>
                                        <th class="text-center">Gastos totales </th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                    <tr v-for="list of listaRango">
                                        <td>{{list.id}}</td>
                                        <td>{{list.fecha_inicio}}</td>
                                        <td>{{list.fecha_fin}}</td>
                                        <td class="text-right">{{list.cant}}</td>
                                        <td class="text-right">{{list.total_gastos}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <button @click="btnGraficaE( fecha1, fecha2)" class="btn btn-warning">Ver grafica</button>
                        <button @click="download1( fecha1, fecha2)" class="btn btn-success">Descargar</button>
                        <div class="col-sm-10" id="idG2">
                            <div class="col-sm-10">
                                <canvas id="graficaE"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Consulta de productores-->
            <div class="tab-pane fade" id="pills-productores" role="tabpanel" aria-labelledby="pills-productores-tab">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="form-inline justify-content-center">
                            <div class="form-group">
                                <!--Lista de embarques actuales-->
                                <label>Consultar por</label>
                                <select class="custom-select custom-select-sm mx-sm-3" @click="mostrarP" id="selectP">
                                    <option value="1">Productores rango de fechas</option>
                                    <option value="2">Productor rango de fecha </option>
                                    <option value="3">Historial de productor</option>
                                    <option value="4">Rendimiento de productores </option>
                                    <option value="6">Abonos</option>
                                    <option value="5">Fotos de fruta</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                </div>
                <br>
                <!--Productores por rango de fecha -->
                <div class="row" id="uno">
                    <div class="col-sm-12">
                        <div class="container-fluid row justify-content-center">
                            <div class="col-sm-12">
                                <div class="row">
                                    <div class="col-sm-8">
                                        <p class="form-inline">Fechas de:&nbsp;
                                            <input @keyup.enter="btnConsultaP(fecha1p, fecha2p)" class="form-control col-sm-3" v-model="fecha1p" type="date"  autofocus>&nbsp; a&nbsp;
                                            <input @keyup.enter="btnConsultaP(fecha1p, fecha2p)" class="form-control col-sm-3" v-model="fecha2p" type="date"  autofocus>
                                        </p>
                                    </div>
                                    <div class="col-sm-4 text-left">
                                        <button type="button" @click="btnConsultaP(fecha1p, fecha2p)" class="btn btn-warning btn-sm col-sm-5">&nbsp;Aceptar</button>
                                        <button type="button" @click="btnPDF3(fecha1p, fecha2p, '#tablaProdfecha')" class="btn btn-danger btn-sm col-sm-5 ml-1"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                    </div>   
                                </div>
                                
                            </div>
                        </div>
                    </div>
                    <!--Inicia tabla -->
                    <div class="col-sm-12" id="ProdFecha">
                        <table id="tablaProdfecha" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">ID</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Kilos</th>
                                    <th class="text-center">Pago total con descuentos</th>
                                    <!--th>Acciones</th-->
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaP" >
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td class="text-right">{{list.kg}}</td>
                                    <td class="text-right">$ {{list.total}}</td>
                                </tr>
                            </tbody>
                            <tfooter>
                                <tr>
                                    <td></td>
                                    <td><strong>Totales</strong></td>
                                    <td class="text-right"><strong>{{totalfech}} Kg´s</strong></td>
                                    <td class="text-right"><strong>$ {{totalDineros}}</strong></td>
                                </tr>
                            </tfooter>
                        </table>
                    </div>
                    
                    <button @click="btnGraficaP(fecha1p, fecha2p)" class="btn btn-warning">Ver grafica</button>
                    
                    <button @click="download2(fecha1p, fecha2p)" class="btn btn-success">Descargar</button>
                    <div id="prodFecha2" class="col-sm-12">
                        <div class="col-sm-10">
                            <img id="url2">
                            <canvas id="graficaP"></canvas>
                        </div>
                    </div>
                </div>
                <!--Productor individual por rango de fechas -->
                <div class="row" id="dos" style="display: none;">
                    <div class="col-sm-12">
                        <div class="container-fluid row">
                            <div class="col-sm-12 form-inline">
                                <div class="row mb-2">
                                    <div class="col-sm-12">
                                        Productor:
                                        <input @keyup.enter="btnConsultaP2(idProd, fecha1p2, fecha2p2)" class="form-control col-sm-2" v-model="idProd"  type="number" min="1" autofocus>&nbsp;
                                        Fechas de:
                                        <input @keyup.enter="btnConsultaP2(idProd, fecha1p2, fecha2p2)" class="form-control col-sm-3" v-model="fecha1p2" type="date"  autofocus>&nbsp;a&nbsp;
                                        <input @keyup.enter="btnConsultaP2(idProd, fecha1p2, fecha2p2)" class="form-control col-sm-3" v-model="fecha2p2" type="date"  autofocus>&nbsp;
                                        <button type="button" @click="btnConsultaP2(idProd, fecha1p2, fecha2p2)" class="btn btn-warning btn-sm col-sm-1">Aceptar&nbsp;</button>
                                        <button type="button" @click=" btnPDF4(idProd, fecha1p2, fecha2p2, '#productorIndividual')" class="btn btn-danger btn-sm col-sm-1"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--Inicia tabla -->
                    <div class="col-sm-12" id="fechaProd1">
                        <table id="productorIndividual" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Id Productor</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Kilos</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaP2" > 
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td>{{list.peso}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <button @click="btnGraficaP2(idProd, fecha1p2, fecha2p2)" class="btn btn-warning">Ver grafica</button>
                    <button @click="download3(idProd, fecha1p2, fecha2p2)" class="btn btn-success">Descargar</button>
                    
                    <div class="col-sm-10" id="fechaProd2">
                        <canvas id="graficaP2"></canvas>
                        <img id="url3">
                    </div>
                </div>
                <!--Productor historial-->
                <div class="row" id="tres" style="display: none;">
                    <div class="col-sm-12">
                        <div class="container-fluid row justify-content-center">
                            <div class="col-sm-12">
                                <div class="row">
                                    <p class="col-sm-8 form-inline">Id Productor: &nbsp;
                                        <input @keyup.enter="btnConsultaP3(idProd2)" class="form-control col-sm-3" v-model="idProd2" type="number" min="1"  autofocus>&nbsp;
                                        <button type="button" @click="btnConsultaP3(idProd2)" class="btn btn-warning btn-sm col-sm-2">Aceptar &nbsp; </button>
                                    </p>
                                    <div class="col-sm-4 text-left">
                                        <button type="button" @click="btnPDF5(idProd2, '#tablaHistorial')" class="btn btn-danger btn-sm col-sm-5"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--Inicia tabla -->
                    <div class="col-sm-12" id="prod1">
                        <table id="tablaHistorial" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Embarque</th> 
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Kilos</th>
                                    <th class="text-center">Rendimiento</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaP3" > 
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td class="text-right">{{list.peso}}</td>
                                    <td class="text-right">{{list.rend}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <button @click="btnGraficaP3()" class="btn btn-warning">Ver grafica</button>
                    
                    <button @click="download4(idProd)" class="btn btn-success">Descargar</button>
                    <div class="col-sm-12" id="prod2"> <br>
                        <div class="row">
                            <div class="col-sm-10">
                                <canvas id="graficaP3"> </canvas>
                            </div>
                            <div class="col-sm-10">
                                <canvas id="graficaRend"> </canvas>
                            </div>
                            <br>
                        </div>
                    </div>
                </div>
                <!--Productor rendimiento-->
                <div class="row" id="cuatro" style="display: none;">

                    <div class="col-sm-12">
                        <div class="container-fluid row justify-content-center">
                        <div class="col col-sm-12  form-check-inline">
                            <div class="col-sm-12 col-md-4">
                                <p>
                                    
                                    <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="option1" @click="ocFechaAbon">
                                    <label class="form-check-label" for="inlineRadio1">Por embarque</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="option2" @click="ocFechaAbon2">
                                    <label class="form-check-label" for="inlineRadio2">Por fecha</label>
                                    </div>
                                </p>
                               </div>
                              
                        </div> <br>
                            <div class="col-sm-12 form-inline">
                                <p class="col-sm-12 col-md-4">
                                    <select style="width: 230px;" v-model="idPro" class="form-control" multiple>
                                        <option value="9999" >&nbsp; - Todos los productores</option>
                                        <option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
                                        {{lp.id}} - {{lp.nombre}} {{lp.Ap_p}} {{lp.Ap_m}}</option>
                                    </select>
                                </p>
                                <p id="abono1">Embarque:&nbsp;
                                    <input @keyup.enter="btnConsultaP4(idPro,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb" type="number"  autofocus>&nbsp; a&nbsp;
                                    <input @keyup.enter="btnConsultaP4(idPro,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                    <button type="button"  @click="btnConsultaP4(idPro,idEmb, idEmb2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                    <button type="button" @click="btnPDF6( idEmb, idEmb2, '#tablaRendimiento1')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </p>
                                <p id="abono2" style="display: none;">Fechas&nbsp;
                                <input @keyup.enter="btnConsultaP4Fecha(idPro,fech1, fech2)" class="form-control col-sm-4" v-model="fech1" type="date"  autofocus>&nbsp; a&nbsp;
                                <input @keyup.enter="btnConsultaP4Fecha(idPro,fech1, fech2)" class="form-control col-sm-4" v-model="fech2" type="date"  autofocus>&nbsp;
                                <button type="button"  @click="btnConsultaP4Fecha(idPro,fech1, fech2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                <button type="button"  @click="btnPDF8( fech1, fech2, '#tablaRendimiento2')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                            </p>
                            </div>
                        </div>
                    </div>
                    <!--Inicia tabla -->
                    <div class="col-sm-12" id="tAbon1">
                        <table id="tablaRendimiento1" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                 <!--   <th class="text-center">Id Embarque</th>-->
                                    <th class="text-center">Id Productor</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Kilos</th>
                                    <th class="text-center">Rendimiento</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaP4" >  
                                    <!--<td>{{list.embarque}}</td>-->
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td class="text-right">{{list.kg}}</td>
                                    <td class="text-right">{{list.rend}}</td>
                                </tr>
                            </tbody>
                            <tfooter>
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td class="text-right"><strong>Total: </strong>{{totalfech}}</td>
                                    <td></td>
                                </tr>
                            </tfooter>
                        </table>
                    </div>
                    <div class="col-sm-12" id="tAbon2"  style="display: none;">
                        <table id="tablaRendimiento2" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                  <!--  <th class="text-center">Id Embarque</th>-->
                                    <th class="text-center">Id Productor</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Kilos</th>
                                    <th class="text-center">Rendimiento</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list of listaP4Fecha" >  
                                   <!-- <td>{{list.embarque}}</td>-->
                                    <td>{{list.id}}</td>
                                    <td>{{list.nombre}}</td>
                                    <td class="text-right">{{list.kg}}</td>
                                    <td class="text-right">{{list.rend}}</td>
                                </tr>
                            </tbody>
                            <tfooter>
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td class="text-right"><strong>Total: </strong>{{totalfech}}</td>
                                    <td></td>
                                    <td></td>
                                </tr>
                            </tfooter>
                        </table>
                    </div>
                    <div id="btn1Abon">
                    <button  @click="btnGraficaP4(idEmb, idEmb2)" class="btn btn-warning">Ver grafica</button>
                    <button @click="download5(idEmb, idEmb2)" class="btn btn-success">Descargar</button>
                    </div>
                    <div id="btn2Abon" style="display: none;">
                    <button  @click="btnGraficaP4fecha(fech1, fech2)" class="btn btn-warning" >Ver grafica</button>
                    <button @click="download5f(fech1, fech2)" class="btn btn-primary">Descargar</button>
                    </div>
                   
                    
                   <div class="col-sm-10" id="emb2">
                        <canvas id="graficaP4"> </canvas>
                        <img id="url5">
                    </div>
                </div>
                 <!-- Abonos de productores-->
                 <div class="row" id="seis" style="display: none;">

                    <div class="col-sm-12">
                    <div class="container-fluid row justify-content-center">
                    <div class="col col-sm-12  form-check-inline">
                        <div class="col-sm-12 col-md-4">
                            <p>
                                
                                <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="option1" @click="ocFechaRen">
                                <label class="form-check-label" for="inlineRadio1">Por embarque</label>
                                </div>
                                <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="option2" @click="ocFechaRen2">
                                <label class="form-check-label" for="inlineRadio2">Por fecha</label>
                                </div>
                            </p>
                            </div>
                            
                    </div> <br>
                        <div class="col-sm-12 form-inline">
                            <p class="col-sm-12 col-md-4">
                                <select style="width: 230px;" v-model="idPro" class="form-control" multiple>
                                    <option value="9999" >&nbsp; - Todos los productores</option>
                                    <option v-for="lp of listaProductor" :key="lp.id" v-bind:value="lp.id">
                                    {{lp.id}} - {{lp.nombre}}  {{lp.Ap_p}} {{lp.Ap_m}}</option>
                                </select>
                            </p>
                            <p id="rendimeinto1">Embarque:&nbsp;
                                <input @keyup.enter="btnAbonoEmb(idPro,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb" type="number"  autofocus>&nbsp; a&nbsp;
                                <input @keyup.enter="btnAbonoEmb(idPro,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                <button type="button"  @click="btnAbonoEmb(idPro,idEmb, idEmb2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                <button type="button"  @click="btnPDF9('#abono1Prod',idEmb, idEmb2)" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                            </p>
                            <p id="rendimeinto2" style="display: none;">Fechas&nbsp;
                            <input @keyup.enter="btnAbonoFecha(idPro,fech1, fech2)" class="form-control col-sm-4" v-model="fech1" type="date"  autofocus>&nbsp; a&nbsp;
                            <input @keyup.enter="btnAbonoFecha(idPro,fech1, fech2)" class="form-control col-sm-4" v-model="fech2" type="date"  autofocus>&nbsp;
                            <button type="button"  @click="btnAbonoFecha(idPro,fech1, fech2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                            <button type="button"  @click="btnPDF10('#abono2Prod', fech1, fech2)" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                        </p>
                        </div>
                    </div>
                    </div>
                    <!--Inicia tabla -->
                    <div class="col-sm-12" id="rend1">
                    <table id="abono1Prod" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                        <thead>
                            <tr class="bg-dark text-light">
                                <th class="text-center">Id Productor</th>
                                <th class="text-center">Embarque</th>
                                <th class="text-center">Nombre</th>
                                <th class="text-center">Préstamos</th>
                                <th class="text-center">Fungicida</th>
                                <th class="text-center">Fertilizante</th>
                                <th class="text-center">Abono préstamos</th>
                                <th class="text-center">Abono fungicida</th>
                                <th class="text-center">Abono fertilizante</th>
                            </tr>
                        </thead>
                        <tbody  class="table" id="tablass">
                            <tr v-for="list of listAboEmb" >  
                            <td>{{list.id}}</td>
                                <td>{{list.embarque}}</td>
                                <td>{{list.nombre}}</td>
                                <td>{{list.prestamo}}</td>
                                <td>{{list.fungicida}}</td>
                                <td>{{list.fertilizante}}</td>
                                <td>{{list.abono_prestamo}}</td>
                                <td>{{list.abono_fungicida}}</td>
                                <td>{{list.abono_fertilizante}}</td>
                            </tr>
                        </tbody>
                    </table>
                    </div>
                    <div class="col-sm-12" id="rend2"  style="display: none;">
                    <table id="abono2Prod" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                        <thead>
                        <tr class="bg-dark text-light">
                                <th class="text-center">Id Productor</th>
                                <th class="text-center">Embarque</th>
                                <th class="text-center">Nombre</th>
                                <th class="text-center">Préstamos</th>
                                <th class="text-center">Fungicida</th>
                                <th class="text-center">Fertilizante</th>
                                <th class="text-center">Abono préstamos</th>
                                <th class="text-center">Abono fungicida</th>
                                <th class="text-center">Abono fertilizante</th>
                            </tr>
                        </thead>
                        <tbody  class="table" id="tablass">
                            <tr v-for="list of listAboFech" >  
                                
                                <td>{{list.id}}</td>
                                <td>{{list.embarque}}</td>
                                <td>{{list.nombre}}</td>
                                <td>{{list.prestamo}}</td>
                                <td>{{list.fungicida}}</td>
                                <td>{{list.fertilizante}}</td>
                                <td>{{list.abono_prestamo}}</td>
                                <td>{{list.abono_fungicida}}</td>
                                <td>{{list.abono_fertilizante}}</td>
                            </tr>
                        </tbody>
                    </table>
                    </div>


                    </div>
                <!-- Foto de frutas -->
                <div class="row" id="cinco" style="display: none;">
                    <div class="col-sm-12">
                        <div class="container-fluid row justify-content-center">
                            <div class="col-sm-12">                                
                                <div class="form-inline">Embarque&nbsp;
                                    <input @keyup.enter="btnConsultaFoto(idEmbarque, idProductor)" class="form-control col-sm-3 col-md-2" v-model="idEmbarque" type="number"  autofocus>
                                    &nbsp;&nbsp;&nbsp; Productor:&nbsp;
                                    <input @keyup.enter="btnConsultaFoto(idEmbarque, idProductor)" class="form-control col-sm-3 col-md-2" v-model="idProductor" type="number"  autofocus>&nbsp;
                                    <button type="button" @click="btnConsultaFoto(idEmbarque, idProductor)" class="btn btn-warning btn-sm">Aceptar &nbsp; </button>

                                </div>
                            </div>
                            <div class="col-sm-12 form-inline mt-5">
                                <div class="col-sm-4 col-md-3 col-lg-2 mb-1" v-for="list of listaFrutaP">
                                    <div class="card text-center" style="cursor: pointer;">
                                        <img v-bind:src="list.foto" class="card-img-top" alt="Card image cap" @click="verFoto(list.foto)">
                                        <div class="card-body">
                                            <p class="card-text">Peso: {{list.peso}} kg</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
         <!--Consulta trabajadores -->
         <div class="tab-pane fade " id="pills-trabajadores" role="tabpanel" aria-labelledby="pills-trabajadores-tab">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="form-inline justify-content-center">
                            <div class="form-group">
                                <!--Lista de embarques actuales-->
                                <label>Consultar</label>
                                <select class="custom-select custom-select-sm mx-sm-3" @click="mostrarT" id="selectT">
                                    <option value="1">Bolsas peladores</option>
                                    <option value="2">Aguinaldo por fecha</option>
                                    <option value="3">Aguinaldo por embarque</option>
                                    <option value="4">Pago bolseros</option>
                                    <option value="5">Pago peladores</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <br>
                </div>
                <!-- Bolsas peladores-->
             
                <div class="row" id="t1">

                    <div class="col-sm-12">
                        <div class="container-fluid row justify-content-center">
                        <div class="col col-sm-12  form-check-inline">
                            <div class="col-sm-12 col-md-4">
                                <p>
                                    <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="option1" @click="ocultarFech1">
                                    <label class="form-check-label" for="inlineRadio1">Por embarque</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="option2" @click="ocultarEmb1">
                                    <label class="form-check-label" for="inlineRadio2">Por fecha</label>
                                    </div>
                                </p>
                            </div>
                        </div>
                        <br>
                        <div class="col-sm-12 form-inline">
                            
                            <p class="col-sm-12 col-md-4">
                                <select style="width: 230px;" v-model="idPel" class="form-control" multiple>
                                    <option value="9999" >&nbsp; - Todos los peladores </option>
                                    <option v-for="lp of listaTrabP" :key="lp.id" v-bind:value="lp.id">
                                    {{lp.id}} - {{lp.nombre}}  {{lp.Ap_p}} {{lp.Ap_m}}</option>
                                </select>
                            </p>
                    
                            <p id="trabajador1" >Embarque:&nbsp;
                                <input @keyup.enter="btnConsultaT1(idPel,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb" type="number"  autofocus>&nbsp; a&nbsp;
                                <input @keyup.enter="btnConsultaT1(idPel,idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                <button type="button"  @click="btnConsultaT1(idPel,idEmb, idEmb2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                <button type="button"  @click="btnPDF11( idEmb, idEmb2, '#tablat1')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                            </p>
                            <p id="trabajador2" style="display: none;">Fechas&nbsp;
                                <input @keyup.enter="btnConsultaT2(idPel,fech1, fech2)" class="form-control col-sm-4" v-model="fech1" type="date"  autofocus>&nbsp; a&nbsp;
                                <input @keyup.enter="btnConsultaT2(idPel,fech1, fech2)" class="form-control col-sm-4" v-model="fech2" type="date"  autofocus>&nbsp;
                                <button type="button"  @click="btnConsultaT2(idPel,fech1, fech2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                <button type="button"  @click="btnPDF12( fech1, fech2, '#tablat2')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                            </p>
                        </div>
                           

                        </div>
                    </div>
                <!--Inicia tabla -->
                    <div class="col-sm-12" id="bolsasP1">
                        <table id="tablat1" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Id Pelador</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Cantidad</th>
                                    <th class="text-center">Pago</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                            <tr v-for="list of listaPB" >  
                                    <td class="text-left">{{list.id_pelador}}</td>
                                    <td class="text-left">{{list.nombre}}</td>
                                    <td class="text-right">{{list.bolsas}}</td>
                                    <td class="text-right">$ {{list.pago_pe}}</td>
                                </tr>
                            </tbody>
                            <tfooter>
                                <tr>
                                    <td></td>
                                    <td><strong>Total: </strong></td>
                                    <td class="text-right font-weight-bold">{{totalfech}}</td>
                                    <td class="text-right font-weight-bold">$ {{totalpago}}</td>
                                </tr>
                            </tfooter>
                        </table>
                    </div>

                    <div class="col-sm-12" id="bolsasP2" style="display: none;">
                        <table id="tablat2" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Id Pelador</th>
                                    <th class="text-center">Nombre</th>
                                    <th class="text-center">Fecha</th>
                                    <th class="text-center">Cantidad</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                            <tr v-for="list of listaPBFecha" >  
                                    <td class="text-left">{{list.id_pelador}}</td>
                                    <td class="text-left">{{list.nombre}}</td>
                                  <!--  <td class="text-left">{{list.id_embarque}}</td>-->
                                    <td class="text-left">{{list.fecha}}</td>
                                    <td class="text-right">{{list.bolsas}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                 <div id="btn1">
                 <button  @click="btnGraficaT1(idEmb, idEmb2)" class="btn btn-warning">Ver grafica</button>
                    <button @click="download7(idEmb, idEmb2)" class="btn btn-success">Descargar</button>
                 </div>
                    
                  <div id="btn2" style="display: none;">
                  <button  @click="btnGraficaT1fecha(fech1, fech2)" class="btn btn-warning" >Ver grafica</button>
                    <button @click="download8(fech1, fech2)" class="btn btn-success">Descargar</button>
                  </div>
                    <div class="col-sm-10" id="graficat1">
                        <canvas id="graficaT1Canvas"> </canvas>
                
                    </div>
                </div>
                <!--Aguinaldo por fecha-->
                <br>
                <div class="row" id="t2" style="display: none;">
                    <div class="col col-sm-12">
                        <div class="container-fluid row">
                            <div class="col-sm-12 form-inline">
                                <div class="col-sm-8 form-inline">Fechas de: &nbsp; 
                                    <input @keyup.enter="btnAguinaldoFecha(fecha1, fecha2)" class="form-control col-sm-4" id="fecha1" v-model="fecha1" type="date"  autofocus>&nbsp; a &nbsp;
                                    <input @keyup.enter="btnAguinaldoFecha(fecha1, fecha2)" class="form-control col-sm-4" id="fecha2" v-model="fecha2" type="date"  autofocus>&nbsp;
                                </div>
                                <div class="col-sm-4 text-left">
                                    <button type="button" @click="btnAguinaldoFecha(fecha1, fecha2)" class="btn btn-warning btn-sm col-sm-5">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF13( fecha1, fecha2,'#tablat3')" class="btn btn-danger btn-sm col-sm-5 ml-1"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </div>
                            </div>
                        </div>
                    </div><br>
                    <!-- Tabla -->
                    <div class="col-sm-12">
                        <table id="tablat3" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Embarque</th>
                                    <th class="text-center">Aguinaldo</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                            <tr v-for="list of listAguiFech">                                    
                                    <td class="text-left">{{list.id_embarque}}</td>
                                    <td class="text-right">$ {{list.aguinaldo}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <button  @click="btnGraficaAguinaldofecha(fecha1, fecha2)" class="btn btn-warning" >Ver grafica</button>
                    <button @click="download9(fecha1, fecha2)" class="btn btn-success">Descargar</button>
                    <div class="col-sm-10" id="aguinaldoFecha">
                        <canvas id="graficaAguinaldofecha"> </canvas>
                
                    </div>
                </div>
                <!--Aguinaldo por embarque-->
              
                <div class="row" id="t3" style="display: none;">
                <div class="col col-sm-12">
                        <div class="container-fluid row">
                            <div class="col-sm-12 form-inline">
                                <div class="col-sm-8 form-inline">Embarques&nbsp; 
                                    <input @keyup.enter="  btnAguinaldoEmb(idEmb, idEmb2)" class="form-control col-sm-4"  v-model="idEmb" type="number"  autofocus>&nbsp; a &nbsp;
                                    <input @keyup.enter="  btnAguinaldoEmb(idEmb, idEmb2)" class="form-control col-sm-4" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                </div>
                                <div class="col-sm-4 text-left">
                                    <button type="button" @click="  btnAguinaldoEmb(idEmb, idEmb2)" class="btn btn-warning btn-sm col-sm-5">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF14( idEmb, idEmb2,'#tablat4')" class="btn btn-danger btn-sm col-sm-5 ml-1"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </div>
                            </div>
                        </div>
                    </div><br>

                    <!--Tabla-->
                    <div class="col-sm-12" >
                        <table id="tablat4" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Embarque</th>
                                    <th class="text-center">Aguinaldo</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                            <tr v-for="list of listAguiEmb">
                                    <td class="text-left">{{list.id_embarque}}</td>
                                    <td class="text-right">$ {{list.aguinaldo}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <button  @click="btnGraficaAguinaldo (idEmb, idEmb2)" class="btn btn-warning" >Ver grafica</button>
                    <button @click="download10(idEmb, idEmb2)" class="btn btn-success">Descargar</button>
                    <div class="col-sm-10" id="aguinaldoEmb">
                        <canvas id="graficaAguinaldoEmb"> </canvas>
                
                    </div>
                </div>
                 <!--Pagos Bolseros-->
                 <div class="row" id="t4" style="display: none;">
                        <div class="col-sm-12">
                            <div class="container-fluid row justify-content-center">
                            <div class="col col-sm-12  form-check-inline">
                                <div class="col-sm-12 col-md-4">
                                    <p>
                                        
                                        <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="option1" @click="ocultarFech2">
                                        <label class="form-check-label" for="inlineRadio1">Por embarque</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="option2" @click="ocultarEmb2">
                                        <label class="form-check-label" for="inlineRadio2">Por fecha</label>
                                        </div>
                                    </p>
                                </div>
                                
                            </div> <br>
                            <div class="col-sm-12 form-inline">
                                
                                <p class="col-sm-12 col-md-4">
                                    <select style="width: 230px;" v-model="idBol" class="form-control" multiple>
                                        <option value="9999" >&nbsp; - Todos los bolseros </option>
                                        <option v-for="lp of listaB" :key="lp.id" v-bind:value="lp.id">
                                        {{lp.id}} - {{lp.nombre}}  {{lp.Ap_p}} {{lp.Ap_m}}</option>
                                    </select>
                                </p>

                                <p id="trabajador11" >Embarque:&nbsp;
                                    <input @keyup.enter="btnConsultaTBol(idBol, idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb" type="number"  autofocus>&nbsp; a&nbsp;
                                    <input @keyup.enter="btnConsultaTBol(idBol, idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                    <button type="button"  @click="btnConsultaTBol(idBol, idEmb, idEmb2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF15( idEmb, idEmb2,'#tablat5')"  class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </p>
                                <p id="trabajador22" style="display: none;">Fechas&nbsp;
                                    <input @keyup.enter="btnConsultaTBolFech(idBol, fech1, fech2)" class="form-control col-sm-4" v-model="fech1" type="date"  autofocus>&nbsp; a&nbsp;
                                    <input @keyup.enter="btnConsultaTBolFech(idBol, fech1, fech2)" class="form-control col-sm-4" v-model="fech2" type="date"  autofocus>&nbsp;
                                    <button type="button"  @click="btnConsultaTBolFech(idBol, fech1, fech2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF16( fech1, fech2,'#tablat6')"  class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </p>
                            </div>
                            

                            </div>
                        </div>
                        <!--Inicia tabla -->
                        <div class="col-sm-12" id="bolsasB1">
                            <table id="tablat5" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">Id Bolsero</th>
                                        <th class="text-center">Nombre</th>
                                        <th class="text-center">Cantidad</th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                <tr v-for="list of listaBPagoEmb" >  
                                        <td class="text-left">{{list.id_bolsero}}</td>
                                        <td class="text-left">{{list.nombre}}</td>
                                        <td class="text-right">{{list.pago}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="col-sm-12" id="bolsasB2" style="display: none;">
                            <table id="tablat6" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">Id Bolsero</th>
                                        <th class="text-center">Nombre</th>
                                        <th class="text-center">Cantidad</th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                <tr v-for="list of listaBPagoFech" >  
                                        <td class="text-left">{{list.id_bolsero}}</td>
                                        <td class="text-left">{{list.nombre}}</td>
                                        <td class="text-right">{{list.pago}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div  id="btn11">
                        <button @click="btnGraficaPagoBol(idEmb, idEmb2)" class="btn btn-warning">Ver grafica</button>
                    <button @click="download11(idEmb, idEmb2)" class="btn btn-success">Descargar</button>
                        </div>

                        <div id="btn22" style="display: none;">
                        <button  @click="btnGraficaPagoBolFecha( fech1, fech2)" class="btn btn-warning" >Ver grafica</button>
                    <button @click="download12( fech1, fech2)" class="btn btn-success">Descargar</button>
                        </div>
                        <div class="col-sm-10" id="emb2">
                            <canvas id="graficaPagoBol"> </canvas>

                        </div>

                  </div>
                   <!--Pagos peladores-->
                <div class="row" id="t5" style="display: none;">
                <div class="col-sm-12">
                            <div class="container-fluid row justify-content-center">
                            <div class="col col-sm-12  form-check-inline">
                                <div class="col-sm-12 col-md-4">
                                    <p>
                                        
                                        <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio1" value="option1" @click="ocultarPago1">
                                        <label class="form-check-label" for="inlineRadio1">Por embarque</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="inlineRadioOptions" id="inlineRadio2" value="option2" @click="ocultarPago2">
                                        <label class="form-check-label" for="inlineRadio2">Por fecha</label>
                                        </div>
                                    </p>
                                </div>
                                
                            </div> <br>
                            <div class="col-sm-12 form-inline">
                                
                                <p class="col-sm-12 col-md-4">
                                    <select style="width: 230px;" v-model="idPel" class="form-control" multiple>
                                        <option value="9999" >&nbsp; - Todos los peladores </option>
                                        <option v-for="lp of listaTrabP" :key="lp.id" v-bind:value="lp.id">
                                        {{lp.id}} - {{lp.nombre}}  {{lp.Ap_p}} {{lp.Ap_m}}</option>
                                    </select>
                                </p>

                                <p id="pagoPel1" >Embarque:&nbsp;
                                    <input @keyup.enter="btnPagoEmb(idPel, idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb" type="number"  autofocus>&nbsp; a&nbsp;
                                    <input @keyup.enter="btnPagoEmb(idPel, idEmb, idEmb2)" class="form-control col-sm-2" v-model="idEmb2" type="number"  autofocus>&nbsp;
                                    <button type="button"  @click="btnPagoEmb(idPel, idEmb, idEmb2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF17( idEmb, idEmb2,'#tablat7')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </p>
                                <p id="pagoPel2" style="display: none;">Fechas&nbsp;
                                    <input @keyup.enter="btnPagoFecha(idPel, fech1, fech2)" class="form-control col-sm-4" v-model="fech1" type="date"  autofocus>&nbsp; a&nbsp;
                                    <input @keyup.enter="btnPagoFecha(idPel, fech1, fech2)" class="form-control col-sm-4" v-model="fech2" type="date"  autofocus>&nbsp;
                                    <button type="button"  @click="btnPagoFecha(idPel, fech1, fech2)" class="btn btn-warning btn-sm">&nbsp;Aceptar</button>
                                    <button type="button"  @click="btnPDF18( fech1, fech2,'#tablat8')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp;PDF</button>
                                </p>
                            </div>
                            

                            </div>
                        </div>
                        <!--Inicia tabla -->
                        <div class="col-sm-12" id="pago1">
                            <table id="tablat7" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">Id Pelador</th>
                                        <th class="text-center">Nombre</th>
                                       <!-- <th class="text-center">Embarque</th>-->
                                       <!-- <th class="text-center">Fecha</th>-->
                                        <th class="text-center">Cantidad</th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                <tr v-for="list of listPelEmb" >  
                                        <td class="text-left">{{list.id_pelador}}</td>
                                        <td class="text-left">{{list.nombre}}</td>
                                       <!-- <td class="text-left">{{list.id_embarque}}</td>-->
                                       <!-- <td class="text-left">{{list.fecha}}</td>-->
                                        <td class="text-right">$ {{list.pago}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="col-sm-12" id="pago2" style="display: none;">
                            <table id="tablat8" class="table table-striped table-bordered table-hover table-condensed table-sm" >
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">Id Pelador</th>
                                        <th class="text-center">Nombre</th>
                                      <!--  <th class="text-center">Embarque</th>-->
                                      <!--  <th class="text-center">Fecha</th>-->
                                        <th class="text-center">Cantidad</th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                <tr v-for="list of listPelFech" >  
                                <td class="text-left">{{list.id_pelador}}</td>
                                        <td class="text-left">{{list.nombre}}</td>
                                      <!--  <td class="text-left">{{list.id_embarque}}</td>-->
                                       <!-- <td class="text-left">{{list.fecha}}</td>-->
                                        <td class="text-right">$ {{list.pago}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div id="btn1pago">
                                <button  @click="btnPagoPel( idEmb, idEmb2)" class="btn btn-warning">Ver grafica</button>
                            
                                <button @click="download13( idEmb, idEmb2)" class="btn btn-success">Descargar</button>
                        </div>
                        <div  id="btn2pago"  style="display: none;">
                            <button @click="btnPagoPelfecha( fech1, fech2)" class="btn btn-warning">Ver grafica</button>
                            <button @click="download14( fech1, fech2)" class="btn btn-success">Descargar</button>
                        </div>
                        <div class="col-sm-10" id="emb2">
                            <canvas id="graficaPagoPelador"> </canvas>

                        </div>
                </div>
            </div>
            <!-- Gastos generales-->
            <div class="tab-pane fade" id="pills-general" role="tabpanel" aria-labelledby="pills-general-tab">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="form-inline justify-content-center">
                            <div class="form-group">
                                <!--Lista de embarques actuales-->
                                <label>Consultar por</label>
                                <select class="custom-select custom-select-sm mx-sm-3" id="selectG" @click="mostrarG">
                                    <option value="1">Rendimiento de embarques</option>
                                    <option value="2">Gastos por rango de fechas</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <br>
                <div id="gasto">
                    <div class="row" >
                        <div class="col-sm-12">
                            <div class="container-fluid row justify-content-center">
                                <div class="col-sm-12">
                                    <h2>Rendimiento de embarques</h2>
                                    <h6>Se muestran sólos los embarques cuyo rendimiento es óptimo, según los cálculos.</h6>
                                </div>
                            </div>
                        </div>

                        <!--Inicia tabla -->
                        <table id="tablas" class="table table-striped table-bordered table-hover table-condensed table-sm mt-4">
                            <thead>
                                <tr class="bg-dark text-light">
                                    <th class="text-center">Emb.</th>
                                    <th class="text-center">Fecha inicio</th>
                                    <th class="text-center">Fecha fin</th>
                                    <th class="text-center">Bolsas Registradas</th>
                                    <th class="text-center">Perdida</th>
                                    <th class="text-center">Bolsas Existentes</th>
                                    <th class="text-center">Bolsas Toston</th>
                                    <th class="text-center">Total de Gastos</th>
                                    <th class="text-center">Peso (toneladas)</th>
                                    <th class="text-center">Rendimiento</th>
                                </tr>
                            </thead>
                            <tbody  class="table" id="tablass">
                                <tr v-for="list in listaRE">
                                    <td>{{list.id}}</td>
                                    <td>{{list.fecha_inicio}}</td>
                                    <td>{{list.fecha_fin}}</td>
                                    <td>{{list.bolsas}}</td>
                                    <td>{{list.perdida}}</td>
                                    <td>{{list.bolsas_exitentes}}</td>
                                    <td>{{list.bolsas_toston}}</td>
                                    <td>{{list.total_gastos }}</td>
                                    <td>{{list.toneladas}}</td>
                                    <td>{{list.rendimiento}}</td>
                                </tr>
                            </tbody>
                        </table>


                    </div>
                </div>
                <div id="rend" style="display: none;">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="container-fluid row justify-content-center">
                                <div class="col-sm-12">
                                    <div class="row">
                                        <p class="col-sm-10 form-inline">Fechas de: &nbsp; 
                                            <input @keyup.enter="btnConsultaG(fecha1g, fecha2g)" class="form-control col-sm-4" v-model="fecha1g" type="date"  autofocus>&nbsp; a&nbsp;
                                            <input @keyup.enter="btnConsultaG(fecha1g, fecha2g)" class="form-control col-sm-4" v-model="fecha2g" type="date"  autofocus>&nbsp;
                                            <button type="button" @click="btnConsultaG(fecha1g, fecha2g)" class="btn btn-warning btn-sm">Aceptar &nbsp; </button>
                                        </p>
                                        <div class="col-sm-2">
                                            <button type="button" @click="btnPDF7(fecha1g, fecha2g, '#tablaRendimiento')" class="btn btn-danger btn-sm"><i class="zmdi zmdi-download text-white"></i>&nbsp; PDF</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="gasto1" class="col col-sm-12">
                            <!--Inicia tabla -->
                            <table id="tablaRendimiento" class="table table-striped table-bordered table-hover table-condensed table-sm mt-4">
                                <thead>
                                    <tr class="bg-dark text-light">
                                        <th class="text-center">Id Embarque</th>
                                        <th class="text-center">Fecha inicio</th>
                                        <th class="text-center">Fecha fin</th>
                                        <th class="text-center">Gasto</th>                                    
                                        <th class="text-center">Concepto</th>
                                        <th class="text-center">Cantidad</th>
                                    </tr>
                                </thead>
                                <tbody  class="table" id="tablass">
                                    <tr v-for="list of lista1">
                                        <td>{{list.id}}</td>
                                        <td>{{list.fecha_inicio}}</td>
                                        <td>{{list.fecha_fin}}</td>
                                        <td>{{list.nombre}}</td>
                                        <td>{{list.extra}}</td>
                                        <td class="text-right ">$ {{list.cantidad}}</td>
                                    </tr>
                                    <tr  v-for="list of lista2">
                                        <td colspan="5" class="text-right  font-weight-bold">Total: &nbsp;</td>
                                        <td class="text-right  font-weight-bold ">${{list.total_gastos}}</td>
                                    </tr>
                                </tbody>
                            </table>

                        </div>
                        <div class="col-sm-12">
                            <button @click="btnGrafica(fecha1g, fecha2g)" class="btn btn-warning">Ver grafica</button>
                            <button @click="download6(fecha1g, fecha2g)" class="btn btn-success">Descargar</button>
                        </div>
                        <div class="col-sm-10" id="gasto2">
                            <canvas id="graficaG"> </canvas>
                            <img id="url6">
                        </div>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="pills-reporte" role="tabpanel" aria-labelledby="pills-reporte-tab">
                <div class="col-sm-12">
                    <div class="container row justify-content-left">
                        <div class="col-sm-12">
                            <p class="form-inline">No. Embarque: &nbsp; 
                                <input @keyup.enter="btnEmbarqueReporte(id_reporte)" class="form-control col-sm-2" v-model="id_reporte" type="number" placeholder="Buscar.." autofocus>&nbsp;
                                <button type="submit" @click="btnEmbarqueReporte(id_reporte)" class="btn btn-warning btn-sm col-sm-2">Consultar</button>
                            </p>
                        </div>
                    </div>
                    <table class="table table-striped table-bordered table-hover table-condensed table-sm">
                        <thead class="thead-dark">
                            <th class="text-center"># Embarque</th>
                            <th class="text-center">Fechas</th>
                            <th class="text-center">Productores</th>
                            <th class="text-center">Trabajadores</th>
                            <th class="text-center">Cuentas</th>
                        </thead>
                        <tbody>
                            <tr class="table" v-for="datos of listaDatReporte">
                                <td class="text-center">
                                    {{datos.id}}
                                </td>
                                <td class="text-center">
                                    {{datos.fecha_inicio}} - {{datos.fecha_fin}}
                                </td>
                                <td class="text-center">
                                    <form class="" method="POST" action="<?php echo SERVERURL; ?>vistas/contenido/factura-view.php" target="_blank">
                                        <input type="hidden" name="idEmbarque" v-model="datos.id">
                                        <input type="hidden" name="company" value="<?php echo COMPANY; ?>">
                                        <input type="hidden" name="opc" value="1">
                                        <button class="btn btn-danger btn-sm text-white" type="submit" ><i class="zmdi zmdi-download text-white"></i>&nbsp;Pago de Fruta</button>
                                    </form>
                                </td>
                                <td class="text-center">
                                    <form class="" method="POST" action="<?php echo SERVERURL; ?>vistas/contenido/factura-view.php" target="_blank">
                                        <input type="hidden" name="idEmbarque" v-model="datos.id">
                                        <input type="hidden" name="company" value="<?php echo COMPANY; ?>">
                                        <input type="hidden" name="opc" value="2">
                                        <button class="btn btn-success btn-sm text-white" type="submit" ><i class="zmdi zmdi-download text-white"></i>&nbsp;Pago de Trabajadores</button>
                                    </form>
                                </td>
                                <td class="text-center">
                                    <form class="" method="POST" action="<?php echo SERVERURL; ?>vistas/contenido/factura-view.php" target="_blank">
                                        <input type="hidden" name="idEmbarque" v-model="datos.id">
                                        <input type="hidden" name="company" value="<?php echo COMPANY; ?>">
                                        <input type="hidden" name="opc" value="3">
                                        <button class="btn btn-info btn-sm text-white" type="submit" ><i class="zmdi zmdi-download text-white"></i>&nbsp;Cuentas</button>
                                    </form>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
        <!-- Fin gastos generales-->
    </div>
</div>

