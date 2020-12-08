
const embarque = new Vue({
    el: '#embarques',
    data: {
    //Datos generales
    prodRend:0,
    total_dia_bolsas:0,
        totalPesoProductor:0,
        peso_captura:0,
        listaEmbarques: [], /* Lista de Embarques sin finalizar */
        id: 0, /* Datos para crear un embarque */
        fecha: '', /*  Datos para crear un embarque */
        diaActual: 0, /* Número del dia actual */
        selected: 0, /* Embarque SELECCIONADO*/
        embActual: '', /* Embarque SELECCIONADO - VAR. AUX */
        datosEmbarque: [], /* Datos generales del embarque actual */
        listaTrabP:[], /* Lista de Peladores General*/
        listaTrabB:[], /* Lista de Bolseros General*/
        listaTrabPT:[], /* Lista de Planilla Toston General*/
        listaProductor: [], /* Lista de Trabajadores del día*/
        listaBolserosTodos:[],
        listaPeladoresB:[],
    //Costos de pagos a trabajadores
        pagoPelador:0,
        pagoBolsero:0,
        pagoFruta: 0,
        getPagos:[],
        idBP:'',
    // Datos obtenidos del embarque seleccionado
        noBolsas: 0,
        fecha_dia: '',
        fechaAsis: '',
        b:[],
    // Datos para el registro de fruta
        idProd: 0,
        peso: '',
        precio: 0,
        listaPesos: [],
        listaFrutaP:[],
        listaFruta: [],
        pesasCapturadas: [],

    //Datos pdf
        id_prod:0,
        concepto:'',

    //Tablero
        listaBolsas:[],
        ventanaNew:'',
        auxVentana:'',
    
    //Datos de los asistentes y producción diaria */
        bolserosAsistentes: [],
        id_bolsero:0,
        id_productor: 0,
        listaExtra:[],
        trabajosExtras:[],
        bolsasDia:[],

    //Actualizar Bolsas datos
        prod:0,
        prodAct:0,
        bol:0,
        pel:0,
        bolAct:0,
        pelAct:0,
    
    //Filtrado de Trabajadores 
        filtro: '',
        filtro_2: '',
        filtro_3:'',
        filtro_bolsas: '',
        listaExtras:[],

    //Prestamos
        prestamo_cantidad:0,
        prestamo_tipo:0,
        saldo_insumo:0,
        saldo_prestamo:0,
        abono:0,
        no_pagos:0,
        datosSaldos:[],
        saldoActual:0,
        trabajo:0,

    //Finalizar dia de trabajo
        listaResumen:[],

    //Fializar embarque
        fecha_fin: '',
        contenedor: '',
        sello:'',
        temperatura: 0,
        matricula: '',
        conductor: '',
        perdida:0,
        rendimiento: 0,
        noBolsasExistentes: 0,
        bolsasToston:0
    },
    methods: {

    //Botones Y PRECEDIMIENTOS
    //Boton Nuevo Embarque
        async btnNuevoEmbarque (){
            const { value: formEmbarque } = await Swal.fire({
                title: 'Nuevo Embarque',
                html: '<div class="form-group row">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Número</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="NumeroEmbarque" autofocus>'+
                    '</div></div><div class="form-group row">'+
                    '<label for="fecha" class="col-sm-4 col-form-label text-dark text-right">Fecha Inicio</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" id="FechaEmbarque">'+
                    '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {        
                    return [
                        this.id = document.getElementById('NumeroEmbarque').value,
                        this.fecha = document.getElementById('FechaEmbarque').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#NumeroEmbarque").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#FechaEmbarque").addEventListener("keyup", confirmOnEnter);
                }
            })
            if(this.id == 0 || this.fecha == "" && formEmbarque){
                Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'Embarque no registrado',
                    backdrop: false
                })
            }else {
                this.crearEmbarque();
                Swal.fire({
                    icon: 'success',
                    title: 'Embarque Creado!',
                    text: 'Se ha creado un nuevo embarque',
                    backdrop: false
                })
            }
        },
   
        //Procedimiento CREAR.
        crearEmbarque(){
            //console.log(this.id+" "+this.fecha);
            axios.post(url_embarque, {option:1, id:this.id, fecha:this.fecha}).then(response =>{
                //console.log(response.data);
                if(response.data=="OK"){
                    this.listarEmbarquesActivos();
                    this.id = 0;
                    this.fecha = "";
                }else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrio un error',
                        text: 'No se logro crear el embarque',
                        backdrop: false
                    });
                }
            });
        },

    //Finalizar Embarque
        btnFinalizarEmbarque(){
            Swal.fire({
              title: 'Finalizar Embarque',
              text: "¿Esta seguro que desea finalizar el Embarque "+this.embActual+"?",
              icon: 'warning',
              showCancelButton: true,
              confirmButtonColor: '#3085d6',
              cancelButtonColor: '#d33',
              confirmButtonText: 'Finalizar',
              cancelButtonText: 'Cancelar',
              backdrop: false
            }).then((result) => {
              if (result.value) {
                if(this.embActual != '' && this.fecha_fin != '' && this.contenedor != '' && this.sello != ''
                    && this.matricula != '' && this.temperatura != 0 && this.conductor != '' && this.noBolsas != 0){
                    
                    axios.post(url_embarque, {option:12, embarque:this.embActual, fecha:this.fecha_fin, 
                    contenedor: this.contenedor, sello: this.sello, matricula: this.matricula, 
                    temperatura: this.temperatura, conductor: this.conductor, perdida: this.perdida,
                    bolsas: this.noBolsas, bolsasFinal: this.noBolsasExistentes, rendimiento: this.rendimiento, 
                    pagoPel: this.pagoPelador, bolTos:this.bolsasToston}).then(response =>{
                        //console.log(response.data);
                        /* Recargamos la página */
                        if(response.data=="Ok"){
                            if(this.ventanaNew!=''){
                                this.ventanaNew.close();
                                this.auxVentana='';
                            }
                            location.reload(true);
                        }else{
                            Swal.fire({
                                title: 'Ocurrio un error inesperado',
                                text: "No se logro completar la acción",
                                icon: 'error',
                                backdrop: false
                            }); 
                        }
                    });
                }else{
                   Swal.fire({
                      title: 'Datos incompletos',
                      text: "Complete todos los campos",
                      icon: 'warning',
                      backdrop: false
                   }); 
                }
              }
            })
        },
        listarPeladores(){
            this.total_dia_bolsas=0;
            axios.post(url_embarque,{option:44, emb:this.embActual, fecha:this.fecha_dia}). then(response =>{
                this.listaTrabP = response.data;
                for(d of response.data){
                    this.total_dia_bolsas=(parseInt(this.total_dia_bolsas)+parseInt(d.bolsas));
                }
                //console.log(this.listaTrabP);
            });
        },
    //Cargar datos generales de la empresa
        //Listar Datos
        listarEmbarquesActivos (){
            axios.post(url_embarque,{option:4}).then(response =>{
                this.listaEmbarques = response.data;
                //console.log(this.listaEmbarques);
            });
        },
        //Listar Trabajadpres
        listarTrabajadores (){
            axios.post(url_trabajador,{option:8}). then(response =>{
                this.listaTrabB = response.data;
                //console.log(this.listaTrabB);
            });
            axios.post(url_trabajador,{option:10}). then(response =>{
                this.listaTrabPT = response.data;
                //console.log(this.listaTrabPT);
            });
        },
        //Listar Productores
        listarProductores (){
            axios.post(url_productor,{option:5}). then(response =>{
                this.listaProductor = response.data;
                //console.log(this.listaProductor);
            });
        },
        /* PROCEDIMIENTO para obtener a los asistentes del Día */
        listarAsistentes (){
            axios.post(url_embarque, {option:9, embarque:this.embActual, fechaDia:this.fecha_dia}).then(response =>{
                this.bolserosAsistentes= response.data;
            });
        },
        listarBolserosTodos(){
           
            axios.post(url_embarque, {option:36, embarque:this.embActual, dia:this.diaActual}).then(response =>{
                this.listaBolserosTodos= response.data;
                //console.log(response.data);
             });
        },
        listaPagos(){
            axios.post(url_gastos,{option:6}).then(response =>{
                this.getPagos = response.data;
            });
        },
        cantidadesCostos(){
            this.pagoPelador=0;
            this.pagoBolsero=0;
            for(dat of this.getPagos){
                this.pagoPelador=dat.pago_pelador;
                this.pagoBolsero=dat.pago_bolsero;
                this.pagoFruta=dat.cantidad;
            }
        },
        
        //PROCEDIMIENTO para calcular la fecha del día actual
        fechadelDia (){
            this.fecha_dia = '';
            for(dat of this.datosEmbarque){
                if(dat.fecha_inicio != ''){
                    this.fecha_dia = dat.fecha_inicio;
                    //console.log(this.fecha_dia);
                }
                this.diaActual=dat.dia_actual;
                this.noBolsas=dat.cant_bolsas_embarque;
                //this.rendimiento=parseFloat(this.noBolsas/dat.toneladas).toFixed(4);
            }
            this.fecha_fin=this.fecha_dia;
            //console.log(this.diaActual);
        },
    
    //Botones y Procedimientos para obtener los datos actuales de un embarque
        /* Boton para obtener todos los datos del embarque seleccionado */
        btnCargarDatos (){
            if(this.selected != 0 && this.selected != 'Sin datos...'){
                this.ventanaNew='';
                this.auxVentana='';
                this.embActual = this.selected;
                this.buscardatosEmbarque(this.embActual);
               
            }else{
                Swal.fire({
                    icon: 'error',
                    title: 'Dato no valido',
                    text: 'Selecciones un Número de Embarque',
                    backdrop: false
                });
            }
        },
        buscardatosEmbarque(embarque){
            axios.post(url_embarque,{option:2, id:embarque}).then(response =>{
                this.datosEmbarque = response.data;
                this.fechadelDia();
                this.listaFutas();
                this.listarCapturadas(embarque);
                this.listarAsistentes();
                this.listaBolsasDiarias();
                this.listarExtra();
                this.listarOtrosTrabajos();
                this.camera();

                this.listaFrutaP=null;
                this.cantidadesCostos();
                this.listarPeladoresExtras();
                this.listarBolserosTodos();
                this.listarTrabajadores();
                this.listarPeladores();

                this.obtenerRendimiento(embarque);

            });
        },
        listaFutas (){
            axios.post(url_embarque,{option:7, id:this.embActual, fecha: this.fecha_dia}). then(response =>{
                this.listaFruta = response.data;
                //console.log(this.listaFruta);
            }).catch(e => {
                // Mostramos los errores
                Swal.fire({
                    icon: 'error',
                    title: 'Error de Solicitud HTTP',
                    text: 'Error '+e+', comunique a Soporte la existencia del error.',
                    backdrop: false
                });
            });
        },
    
    //Captura Manual de Fruta
        btnCapturaManual(prod, peso, precio){
            if(precio!=0 && prod!=0){
                Swal.fire({
                    title: 'Registro de Fruta Embarque '+this.embActual,
                    text: 'Se registrara un peso de '+peso+' al prodcutor '+prod,
                    icon: 'warning',
                    showCancelButton: true,
                    showConfirmButton: true,
                    confirmButtonText: 'Registrar',
                    cancelButtonText: 'Cancelar',
                    focusConfirm: true,
                    backdrop: false,
                    confirmButtonColor:'#40B340',
                    cancelButtonColor:'#FF0000',
                }).then((result) => {
                    if (result.value) {
                        axios.post(url_embarque, {option:6, id:prod, peso:peso, embarque: this.embActual, 
                            fecha: this.fecha_dia, img:null, precio: precio}).then(response=>{
                            //le.log(response.data);
                            if(response.data=="OK1null"){
                                Swal.fire({
                                    title: 'Registrado',
                                    text: 'Registro satisfactorio',
                                    icon: 'success',
                                    backdrop: false
                                });
                                this.listaFutas();
                                this.listarCapturadas(this.embActual);
                                this.idProd=0; this.peso_captura=0; this.pretamo_tipo=0;
                            }else{
                                Swal.fire({
                                    title: 'Ocurrio un error inesperado',
                                    text: 'No se logro realizar el registro',
                                    icon: 'error',
                                    backdrop: false
                                });
                            }
                        });
                    }
                });
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    text: 'Verifique que ha llenado todos los campos',
                    icon: 'warning',
                    backdrop: false
                });
            }
        },
        obtenerRendimiento(embarque){
            axios.post(url_embarque, {option:41, id:embarque}).then(response=>{
                for(dat of response.data){
                    this.rendimiento=dat.rendimiento;
                }
            });
        },
        listarCapturadas(id){            
            axios.post(url_embarque, {option:38, id:id}).then(response=>{
                this.pesasCapturadas=response.data;
            });
        },
        btnEliminarPeso(kg, nombre, idF, idPF, pago){
            Swal.fire({
                icon: 'question',
                title: '¿Desea elimnar el registro?',
                text: 'Eliminara '+kg+' kilogamos al productor '+nombre,
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    axios.post(url_embarque, {option:40, embarque:this.embActual, fruta: idF, produc: idPF, 
                    peso: kg, pago: pago}).then(response=>{
                        //console.log(response.data);
                        if(response.data=="OK"){
                            Swal.fire({
                                icon: 'success',
                                title: 'Datos Actualizados',
                                text: 'Se han eliminado correctamente',
                                backdrop: false
                            });
                            this.listarCapturadas(this.embActual);
                            this.obtenerRendimiento(this.embActual);
                        }else{
                            Swal.fire({
                                icon: 'error',
                                title: 'Ocurrio un error inesperado',
                                text: 'No se logro realizar la acción',
                                backdrop: false
                            });
                        }
                    });
                }
            })
        },
        async btnModificarPeso(idF, idPF, nombre, peso, pago){
            var pesoAnt=peso;
            var pagoAnt=pago;
            const { value: modFrutaPesada } = await Swal.fire({
                title: 'Actualizar Datos de Fruta',
                html: '<div class="form-group row">'+
                    '<label for="pelador" class="col-sm-4 col-form-label text-dark text-right">Productor</label>'+
                    '<div class="col-sm-7"><input type="text" disabled class="form-control" id="name-id" value="'+nombre+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label for="bolsero" class="col-sm-4 col-form-label text-dark text-right">Pago</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="pagoNew-id" value="'+pago+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label for="productor" class="col-sm-4 col-form-label text-dark text-right">Peso Kg</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="pesoNew-id" value="'+peso+'">'+
                    '</div></div>',
                backdrop: false,
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Actualizar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {        
                    return [
                        document.getElementById('pagoNew-id').value,
                        document.getElementById('pesoNew-id').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#pagoNew-id").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pesoNew-id").addEventListener("keyup", confirmOnEnter);
                }
            })
            if(modFrutaPesada && modFrutaPesada[0]>0 && modFrutaPesada[1]>0){
                axios.post(url_embarque, {option:39, embarque:this.embActual, fruta: idF, produc: idPF, 
                    peso: pesoAnt, pesoNew: modFrutaPesada[1], pago: pagoAnt, pagoNew: modFrutaPesada[0] }).then(response=>{
                    if(response.data=="OK"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Actualizados',
                            text: 'Se han guardado los cambios',
                            backdrop: false
                        });
                        this.listarCapturadas(this.embActual);
                        this.obtenerRendimiento(this.embActual);
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar la modificación',
                            backdrop: false
                        });
                    }
                });
            }
        },

    //Operaciones de Captura y Prestamos
        async autenticar(id, numero, id_bolsero, pelador, id_productor, opc){
            const { value: formAutenticar } = await Swal.fire({
                title: 'Autenticar Administrador',
                html: '<div class="form-inline col-sm-12 mt-3">'+
                '<label class="control-label col-sm-4" for="UserName">Usuario</label>'+
                '<input required="" class="form-control col-sm-7" id="UserName" name="usuario" type="text" autofocus style="color: #2e7d32;">'+
                '</div>'+
                '<div class="form-inline col-sm-12 mt-3">'+
                '<label class="control-label col-sm-4" for="UserPass">Contraseña</label>'+
                '<input required="" class="form-control col-sm-7" id="UserPass" name="clave" type="password" style="color: #2e7d32;">'+
                '</div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Validar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {
                    return [
                        document.getElementById('UserName').value,
                        document.getElementById('UserPass').value
                    ]
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#UserName").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#UserPass").addEventListener("keyup", confirmOnEnter);
                }
            });
            if (formAutenticar && formAutenticar[0]!= '' && formAutenticar[1]!= '') {
                axios.post(url_login,{option:2, user:formAutenticar[0], pass: formAutenticar[1], valor:opc}).then(response =>{
                    if(response.data=="OK1"){
                        this.idProd=0; this.peso_captura=0;this.prestamo_tipo=0;this.saldo_insumo=0;this.saldo_prestamo=0;this.abono=0;this.no_pagos=0;
                        bontonAtras.style.display = "block";
                        pesar_fruta.style.display = 'none';
                        captura_fruta.style.display = 'block';
                        fotos_pesas.style.display='none';
                        prestamo.style.display = 'none';
                        abono.style.display = 'none';
                        boton_captura.style.display = "none";
                        boton_guardar.style.display = 'block';
                        cargar_camara.style.display = 'none';
                        listaPesasCapturadas.style.display = 'block';

                        this.listarCapturadas(this.embActual);
                        //this.listaFrutaP=[];

                    }else if (response.data=="OK2") {
                        this.btnModificarBolsa(id, numero, id_bolsero, pelador, id_productor);
                    }else if (response.data=="OK3") {
                        this.btnPrestamo();
                    }else if (response.data=="OK4") {
                        this.btnAbono();
                    }else{
                        Swal.fire({title: 'Datos incorrectos', icon:'error', backdrop: false});
                    }
                });
            }else{
                Swal.fire({title: 'Datos incorrectos', icon:'warning', backdrop: false});
            }
        },
        btnVolverCaptura(){
            this.idProd=0; this.peso=0;
            this.prestamo_tipo=0;this.saldo_insumo=0;this.saldo_prestamo=0;this.abono=0;this.no_pagos=0;
            bontonAtras.style.display = 'none';
            pesar_fruta.style.display = 'block';
            captura_fruta.style.display = 'none';
            fotos_pesas.style.display='block';
            prestamo.style.display = 'none';
            abono.style.display = 'none';
            boton_captura.style.display = 'block';
            boton_guardar.style.display = 'none';
            cargar_camara.style.display = 'block';

            listaPesasCapturadas.style.display = 'none';

            this.cantidadesCostos();
            this.idProd=0;
            this.datosSaldos='';
        },
        btnPrestamo(){
            this.idProd=0; this.peso=0;
            this.prestamo_tipo=0;this.saldo_insumo=0;
            this.saldo_prestamo=0;this.abono=0;
            this.no_pagos=0;
            bontonAtras.style.display = 'block';
            pesar_fruta.style.display = 'none';
            captura_fruta.style.display = 'none';
            prestamo.style.display = 'block';
            abono.style.display = 'none';
            boton_captura.style.display = 'none';
            boton_guardar.style.display = 'none';
            cargar_camara.style.display = 'none';
        },
        regPrestamo(){
            if(this.idProd!=0 && this.prestamo_tipo !=0 && this.prestamo_cantidad !=0){
                Swal.fire({
                    title: 'Registro de Prestamo al Productor '+this.idProd,
                    text: 'Se registrará un prestamo al productor '+this.idProd,
                    icon: 'warning',
                    showCancelButton: true,
                    showConfirmButton: true,
                    confirmButtonText: 'Registrar',
                    cancelButtonText: 'Cerrar',
                    backdrop: false,
                    confirmButtonColor:'#40B340',
                    cancelButtonColor:'#FF0000',
                }).then((result) => {
                    if (result.value) {
                        axios.post(url_embarque, {option:26, id:this.idProd, embarque: this.embActual, 
                            tipo: this.prestamo_tipo, cantidad:this.prestamo_cantidad, pagos: this.no_pagos}).then(response=>{
                            //console.log(response.data);
                            if(response.data=="OK1null"){
                                Swal.fire({
                                    title: 'Registrado',
                                    text: 'Registro realizado satisfactoriamente',
                                    icon: 'success',
                                    backdrop: false
                                });
                                this.idProd=0; this.prestamo_cantidad=0; this.prestamo_tipo=0; this.no_pagos=0;
                            }else{
                                Swal.fire({
                                    title: 'Ocurrio un error inesperado',
                                    text: 'No se logro realizar el registro',
                                    icon: 'error',
                                    backdrop: false
                                });
                            }
                        });
                        }
                    });
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    text: 'Verifique que ha llenado todos los campos',
                    icon: 'warning',
                    backdrop: false
                });
            }
        },
        btnAbono(){
            this.idProd=0; this.peso=0;
            this.prestamo_tipo=0;this.saldo_insumo=0;
            this.saldo_prestamo=0;this.abono=0;
            this.no_pagos=0;
            bontonAtras.style.display = 'block';
            pesar_fruta.style.display = 'none';
            captura_fruta.style.display = 'none';
            prestamo.style.display = 'none';
            abono.style.display = 'block';
            boton_captura.style.display = 'none';
            boton_guardar.style.display = 'none';
            cargar_camara.style.display = 'none';
        },
        regAbono(){
            if(this.idProd!=0 && this.prestamo_tipo !=0 && this.abono !=0){
              Swal.fire({
                title: 'Registro de Abono al Productor '+this.idProd,
                text: 'Se registrará un abono de '+this.abono+' al prodcutor '+this.idProd,
                icon: 'warning',
                showCancelButton:true,
                confirmButtonText: 'Registrar',
                cancelButtonText: 'Cerrar',
                backdrop: false,
                confirmButtonColor:'#40B340',
                cancelButtonColor:'#FF0000',
            }).then((result) => {
                if (result.value) {
                    axios.post(url_embarque, {option:28, id:this.idProd, embarque: this.embActual, 
                        tipo: this.prestamo_tipo, cantidad:this.abono}).then(response=>{
                            //console.log(response.data);
                            if(response.data=="OK1null"){
                                Swal.fire({
                                    title: 'Registrado',
                                    text: 'Registro realizado satisfactoriamente',
                                    icon: 'success',
                                    backdrop: false
                                });
                                this.idProd=0; this.abono=0; this.prestamo_tipo=0; this.no_pagos=0;
                                this.datosSaldos='';
                            }else{
                                Swal.fire({
                                    title: 'Abono no registrado',
                                    text: 'El productor no dispone de pago fruta en este embarque',
                                    icon: 'warning',
                                    backdrop: false
                                });
                            }
                        });
                    }
                });
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    text: 'Verifique que ha llenado todos los campos',
                    icon: 'warning',
                    backdrop: false
                });
            }
        },
        datosPrestamo(idProd){
            this.datosSaldos='';
            axios.post(url_embarque, {option:27, idProd:idProd}).then(response=>{
                //console.log(response.data);
                if(response.data!="Error"){
                    this.datosSaldos=response.data;
                }
            }).catch(e => {
                // Mostramos los errores
                Swal.fire({
                    icon: 'error',
                    title: 'Error de Solicitud HTTP',
                    text: 'Error '+e+', comunique a Soporte la existencia del error.',
                    backdrop: false
                });
            });
        },
    
    //Modificar bolsas producidas
        listaBolsasDiarias(){
            axios.post(url_embarque, {option:16, id:this.embActual, fecha:this.fecha_dia}).then(response=>{                
                this.bolsasDia=response.data;
                //console.log(this.bolsasDia)
            }).catch(e=>{
                console.log('Error');
            });
        },
        async btnModificarBolsa(id, numero, id_bolsero, pelador, id_productor){
            const { value: formBosas } = await Swal.fire({
                title: "Actualizar Bolsa #"+numero,
                html: '<div class="form-group row">'+
                    '<label for="pelador" class="col-sm-4 col-form-label text-dark text-right">Pelador</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="pelador-id" value="'+pelador+'">'+
                    '</div></div>'+
                    '<input type="hidden" value="'+pelador+'" id="pelador">'+
                    '<div class="form-group row">'+
                    '<label for="bolsero" class="col-sm-4 col-form-label text-dark text-right">Bolsero</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="bolsero-id" value="'+id_bolsero+'">'+
                    '</div></div>'+
                    '<input type="hidden" value="'+id_bolsero+'" id="bolsero">'+
                    '<div class="form-group row">'+
                    '<label for="productor" class="col-sm-4 col-form-label text-dark text-right">Productor</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="productor-id" value="'+id_productor+'">'+
                    '</div></div>'+
                    '<input type="hidden" value="'+id_productor+'" id="productor">',
                backdrop: false,
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Actualizar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {        
                    return [
                        this.pel = document.getElementById('pelador-id').value,
                        this.pelAct = document.getElementById('pelador').value,
                        this.bol = document.getElementById('bolsero-id').value,
                        this.bolAct = document.getElementById('bolsero').value,
                        this.prod = document.getElementById('productor-id').value,
                        this.prodAct = document.getElementById('productor').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#pelador-id").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#bolsero-id").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#productor-id").addEventListener("keyup", confirmOnEnter);
                }
            })
            if(this.pel != 0 || this.bol != 0 || this.prod != 0){
                this.actualizarBolsa(id, this.pel, this.bol, this.prod, this.pelAct, this.bolAct, this.prodAct);
            }
            this.pel=0, this.bol=0, this.prod=0, this.pelAct=0, this.bolAct=0;
        },
        actualizarBolsa(id, pel, bol, prod, actPel, actBol, actProd){
            axios.post(url_embarque, {option:17, id:id, idPel:pel, idBol:bol, idPrd:prod, 
                actPel: actPel, actBol: actBol, actProd: actProd, fecha: this.fecha_dia, embarque: this.embActual,
                pagoB: this.pagoBolsero, pagoP: this.pagoPelador}).then(response=>{
                //console.log(response.data);
                if(response.data=='OK'){
                    this.listaBolsasDiarias();
                    Swal.fire({
                        icon: 'success',
                        title: 'Datos Actualizados',
                        text: 'Se han guardado los cambios',
                        backdrop: false
                    });
                }else if (response.data=='Error') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrio un error inesperado',
                        text: 'No se logro realizar la modificación',
                        backdrop: false
                    });
                }else if(response.data='ProductorNoEncontrado'){
                    Swal.fire({
                        icon: 'error',
                        title: 'No se encontro al Productor',
                        text: 'El Productor que ha ingresado no tiene registro del día',
                        backdrop: false
                    });
                }
            })
        },
        reimprimir(numero, id_productor, id_bolsero, pelador, hora, fecha){
            Swal.fire({
                title: 'Imprimir Etiqueta',
                text: 'Se imprimira la etiqueta de la bolsa #'+numero,
                icon: 'question',
                showCancelButton: true,
                showConfirmButton: true,
                confirmButtonText: 'Imprimir',
                cancelButtonText: 'Cancelar',
                allowEscapeKey: false,
                allowEnterKey: false,
                backdrop: false,
                confirmButtonColor:'#40B340',
                cancelButtonColor:'#FF0000',
            }).then((result) => {
                if (result.value) {
                    axios.post(url_embarque, {option:29, num: numero, prod: id_productor,
                        bol: id_bolsero, pel:pelador, h:hora, f:fecha, dia: this.diaActual}).then(response=>{
                    });
                }
            });
        },
       
    //Operaciones de Frutas en un embarque
        foto (idProd, peso){
            if( (idProd != 0) && (peso != '')){
                Webcam.freeze();
                // swap button sets
                document.getElementById('pre_take_buttons').style.display = 'none';
                document.getElementById('post_take_buttons').style.display = '';
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    icon: 'error',
                    text: 'Ingrese el Productor y el Peso antes de capturar la Foto.',
                    backdrop: false
                });
            }
        },
        cancel_preview() {
            // cancel preview freeze and return to live camera feed
            Webcam.unfreeze();
            
            // swap buttons back
            document.getElementById('pre_take_buttons').style.display = '';
            document.getElementById('post_take_buttons').style.display = 'none';
        },
        save_photo(idProd, peso) {
            var _self=this;
            Webcam.snap( function(data_uri) {
                document.getElementById('pre_take_buttons').style.display = '';
                document.getElementById('post_take_buttons').style.display = 'none';

                _self.registroFruta(idProd, peso, _self.embActual, _self.fecha_dia, data_uri, _self.pagoFruta);
               
            });
             //_self.listaFrutaProd(idProd, _self.embActual);
             //_self.listaRend(idProd);
             //_self.listarCapturadas(_self.embActual);
             //_self.obtenerRendimiento(_self.embActual);
        },     
        camera(){
            Webcam.set({
                width: 320,
                height: 240,
                dest_width: 640,
                dest_height: 480,
                image_format: 'jpeg',
                jpeg_quality: 90
            });
            Webcam.attach( '#my_camera' );           
        },
        listaRend(idPro){
            axios.post(url_embarque, {option:43, idPro:idPro, idEmb:this.embActual}).then(response =>{
                for(dat of response.data){ 
                    this.prodRend=(parseFloat(dat.rend).toFixed(2));
                }
            });
        },
        listaFrutaProd(idProd, embActual){
            this.totalPesoProductor=0;
            axios.post(url_embarque, {option:8, idProd:idProd, embActual:embActual}).then(response=>{
                this.listaFrutaP=response.data;
                for(dat of response.data){
                    this.totalPesoProductor=(parseFloat(this.totalPesoProductor)+parseFloat(dat.peso)).toFixed(2);
                }
                this.listaRend(this.idProd);
                //console.log(this.listaFrutaP);
            }).catch(e => {
                // Mostramos los errores
                Swal.fire({
                    icon: 'error',
                    title: 'Error de Solicitud HTTP',
                    text: 'Error '+e+', comunique a Soporte la existencia del error.',
                    backdrop: false
                });
            });
        },
        registroFruta (prod, peso, embarque, fecha, img, precio){
          
            axios.post(url_embarque, {option:6, id:prod, peso:peso, embarque:embarque, fecha:fecha, img:img, precio: precio}).then(response =>{
                //console.log(response.data);
                if(response.data=="OK1null"){
                    Swal.fire({
                        title: 'Registrado',
                        text: 'Registro realizado satisfactoriamente',
                        icon: 'success',
                        backdrop: false
                    });
                    this.listaFutas();
                }else{
                    Swal.fire({
                        title: 'Ocurrio un error inesperado',
                        text: 'No se logro realizar el registro',
                        icon: 'error',
                        backdrop: false
                    });
                }
            });

            //this.listaFrutaProd(prod, embarque);
        },

    //Registro de Pago Planilla Toston
        async btnPagoPlanilla(id, tipo){
            var pago=0;
            await Swal.fire({
                title: 'Pago del Embarque ' +this.embActual,
                html: '<div class="form-group row mt-1">'+
                '<label for="pago" class="col-sm-4 col-form-label text-dark text-right">Cantidad</label>'+
                '<div class="col-sm-7"><input type="number" step="0.01" class="form-control" value="0" id="pagoPlanilla" autofocus>'+
                '</div></div>'+
                '<div class="form-group row mt-1">'+
                '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>'+
                '<div class="col-sm-7"><input type="date" class="form-control" value="'+this.fecha_dia+'" id="fechaPlanilla">'+
                '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',
                cancelButtonColor:'#FF0000',
                backdrop: false,
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#pagoPlanilla").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#fechaPlanilla").addEventListener("keyup", confirmOnEnter);
                }
                }).then((result) => {
                    if(result.value){
                        pago = document.getElementById('pagoPlanilla').value,
                        fecha = document.getElementById('fechaPlanilla').value

                        if(pago > 0){
                            /* Registrar Pago en la BD */
                            this.registroPlanilla(id, pago, fecha, this.embActual);                            
                        }else{
                            Swal.fire({
                                title: 'Error al registrar',
                                text: 'La cantidad no es aceptable',
                                icon: 'error',
                                backdrop: false
                            })
                        }

                    }
                });
        },
        registroPlanilla(id_planilla, pago, fecha, embarque){
            axios.post(url_embarque, {option:13, embarque:embarque, id_planilla: id_planilla,
                pago: pago, fecha: fecha}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            title: 'Pago Registrado',
                            text: 'Se ha registrado un pago a Planilla '+id_planilla,
                            icon: 'success',
                            backdrop: false
                        })
                        //this.buscardatosEmbarque(this.embActual);
                    }else{
                        Swal.fire({
                            title: 'Pago No Registrado',
                            text: 'Compruebe los datos, posiblemente la fecha no es valida para este embarque o el trabajador ya tiene un pago registrado.',
                            icon: 'error',
                            backdrop: false
                        })
                    }
            });
        },
    
    //Acciones de Bolseros
        /* Operaciones de Bolseros */
        async btnAsistencia (id, pago_asistencia){
            /* Obtener la fecha de Asistencia y Registrar en la BD*/
            const { value: formAsistencia } = await Swal.fire({
                title: 'Asistencia al Embarque ' +this.embActual,
                html: '<h4 class="col-sm-12 text-center mt-3 mb-3">Bolsero #'+id+'</h4>'+
                    '<div class="form-group row mt-1">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Pago</label>'+
                    '<div class="col-sm-7"><input type="number" step="0.01" class="form-control" value="'+pago_asistencia+'" id="pagoAsistencia" autofocus>'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" value="'+this.fecha_dia+'" id="fechaAsistencia" autofocus>'+
                    '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {
                    return [
                        this.fechaAsis = document.getElementById('fechaAsistencia').value,
                        pago_asistencia = document.getElementById('pagoAsistencia').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#fechaAsistencia").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pagoAsistencia").addEventListener("keyup", confirmOnEnter);
                }
            });
            if (this.fechaAsis == "" && pago_asistencia == 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'Asistencia no registrada',
                    backdrop: false
                })
            } else if(formAsistencia) {
                /* Registrar Asistencia en la BD */
                this.regAsistencia(this.embActual, this.fechaAsis, id, pago_asistencia);
                this.fechaAsis='';
                
            }else{
                //No hacer nada
            }
        },
        /* PROCEDIMIENTO de Registro de Trabajos especiales o extras a Bolseros */
        regTrabajoBolsero(idBolsero, fecha, pago, trabajo, embarque){
             axios.post(url_embarque, {option:22, embarque: embarque, fecha: fecha, id: idBolsero, 
                act: trabajo, pago: pago}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            title: 'Datos registrados',
                            text: 'Se ha registrado un trabajo al bolsero '+idBolsero,
                            icon: 'success',
                            backdrop: false                        
                        });
                        this.listarOtrosTrabajos();
                        this.listarAsistentes();
                    }else{
                        Swal.fire({
                            title: 'Ocurrio un error',
                            text: 'No se logro realizar el registro',
                            icon: 'error',
                            backdrop: false                        
                        });
                    }
             });
        },
        /* PROCEDIMIENTO de Registro de Asistencia */
        regAsistencia (noEmbarque, fecha, id, pago_asistencia){
            axios.post(url_embarque, {option:5, embarque: noEmbarque,fechaDia: fecha, id: id, 
                pago:pago_asistencia}).then(response =>{
                    //console.log(response.data);
                    if(response.data == "OK1null" ){
                        Swal.fire({
                            icon: 'success',
                            title: 'Asistencia Registrada',
                            text: 'Se ha registrado la asistencia a un Bolsero',
                            backdrop: false
                        });
                        this.listarAsistentes();
                        this.listarBolserosTodos();
                    }else if(response.data=="ErrorDuplicado"){
                        Swal.fire({
                            icon: 'warning',
                            title: 'Datos duplicados',
                            text: 'Asistencia no registrada, el trabajador ya fue registrado anteriormente',
                            backdrop: false
                        });
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error',
                            text: 'No se logro registrar los datos',
                            backdrop: false
                        });
                    }
            }).catch(e => {
                // Mostramos los errores
                Swal.fire({
                    icon: 'error',
                    title: 'Error de Solicitud HTTP',
                    text: 'Error '+e+', comunique a Soporte la existencia del error.',
                    backdrop: false
                });
            });
        },
    
    //Operaciones de Bolseros Extras
        async bolseroExtra(fecha){
            var nombre='', apellidos='', edad=0, tel='', dir='', cuenta='', acti='', pago=0, tipo=4, fecha_t='';
            const { value: formExtra } = await Swal.fire({
                    title: 'Registrar Bolsero Extra',
                    width: 700,
                    html: '<div class="form-group row text-white"><label class="col-sm-5 col-form-label text-dark text-right">Nombre</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabajador" autofocus></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellidos</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Edad</label><div class="col-sm-5"><input type="number" class="form-control" id="edad"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Telefono</label><div class="col-sm-5"><input type="text" class="form-control" pattern="[0-9]{0-10}" maxlength="10" id="tel"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Dirección</label><div class="col-sm-5"><input type="text" class="form-control" id="dir" name="dir-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">No. Cuenta</label><div class="col-sm-5"><input type="text" class="form-control" maxlength="16" id="cuenta" name="cuenta-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Trabajo</label><div class="col-sm-5"><input type="text" class="form-control" id="actividad" name="trabajo-reg-actividad"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Pago</label><div class="col-sm-5"><input type="number" step="0.1" class="form-control" id="pago" name="pago-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Fecha</label><div class="col-sm-5"><input type="date" class="form-control" id="fecha" name="feha-reg-trabajador" value="'+fecha+'"></div></div>'+
                    '<input type="hidden" class="form-control" maxlength="16" id="tipo-trabajador" value="'+tipo+'">',
                    focusConfirm: false,
                    showCancelButton: true,
                    cancelButtonText: 'Cancelar',
                    confirmButtonText: 'Registrar',
                    confirmButtonColor:'#40B340',
                    cancelButtonColor:'#FF0000',
                    backdrop: false,
                    preConfirm: () => {    
                        return [
                        nombre = document.getElementById('NombreTrabajador').value,
                        apellidos = document.getElementById('apellidoPaterno').value,
                        tipo = document.getElementById('tipo-trabajador').value,
                        edad = document.getElementById('edad').value,
                        tel = document.getElementById('tel').value,
                        dir = document.getElementById('dir').value,
                        cuenta = document.getElementById('cuenta').value,
                        acti = document.getElementById('actividad').value,
                        pago = document.getElementById('pago').value,
                        fecha_t = document.getElementById('fecha').value
                        ]
                    },
                    onOpen: (modal) => {
                        confirmOnEnter = (event) => {
                            if (event.keyCode === 13) {
                                event.preventDefault();
                                modal.querySelector(".swal2-confirm").click();
                            }
                        };
                        modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                        modal.querySelector("#fecha").addEventListener("keyup", confirmOnEnter);
                    }
                })
                if(nombre == "" || apellidos == "" ||
                    edad == 0 || dir =="" || acti == "" || pago == 0){
                    Swal.fire({
                        icon: 'warning',
                        title: 'Datos incompletos',
                        text: 'Datos no registrados',
                        backdrop: false
                    });
                }else {
                    this.registrarBolseroExtra(nombre, apellidos, edad, dir, tel, cuenta, acti, pago, this.embActual, fecha_t);
                }
        },
        registrarBolseroExtra(nombre, apellidos, edad, dir, tel, cuenta, acti, pago, embarque, fecha){
            axios.post(url_embarque, {option:18, id:embarque, nombre: nombre, apellidos: apellidos, edad: edad,
                dir:dir, tel:tel, cuenta: cuenta, acti: acti, pago: pago, fecha: fecha}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Registrados',
                            text: 'Se registro al Trabajador',
                            backdrop: false
                        });
                        this.listarExtra();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar al Trabajador',
                            backdrop: false
                        });
                    }
            });
        },
        listarExtra(){
            axios.post(url_embarque, {option:19, id:this.embActual}).then(response =>{
                this.listaExtra=response.data;
            }); 
        },
    
    //Pelador Trabajo extra
        async btnNewTrabajo(id){
            var fecha='', pago=0, actividad='', concepto='';
            const { value: formOtro} = await Swal.fire({
                title: 'Asignar Trabajo',
                html: '<h4 class="col-sm-12 text-center mt-3 mb-3">Pelador #'+id+'</h4>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-3 col-form-label text-dark text-right">Pago</label>'+
                    '<div class="col-sm-7"><input type="number" step="0.01" class="form-control" value="0" id="pago" autofocus>'+
                    '</div></div>'+
                    '<div class="form-group row"><label class="col-sm-3 col-form-label text-dark text-right">Actividad</label><div class="col-sm-7">'+
                    '<select class="form-control" name="tipo-reg-admin" required id="optionsPrivilegio"><option selected value="2">Bolsero</option><option value="1">Otra actividad</option>'+
                    '</select></div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-3 col-form-label text-dark text-right">Consepto</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" value="" id="concepto">'+
                    '<div class="form-group row mt-1">'+
                    '</div></div>'+
                    '<label for="numero" class="col-sm-3 col-form-label text-dark text-right">Fecha</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" value="'+this.fecha_dia+'" id="fecha">'+
                   '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Asignar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {
                    return[
                        fecha = document.getElementById('fecha').value,
                        pago = document.getElementById('pago').value,
                        concepto = document.getElementById('concepto').value,
                        actividad = document.getElementById('optionsPrivilegio').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#fecha").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#concepto").addEventListener("keyup", confirmOnEnter);
                }
            });
            if(pago!=0 && fecha != '' && formOtro){
                this.regTrabajoPelador(id, fecha, pago, actividad, this.embActual, concepto);
            }else if(pago==0 && fecha == '' && formOtro){
                Swal.fire({
                    title: 'Datos incompletos',
                    text: 'No se completaron los campos',
                    icon: 'warning',
                    backdrop: false
                });
            }else{
                //NO hacer nada
            }
        },
        regTrabajoPelador(id_pelador, fecha, pago, trabajo, embarque, concepto){

            axios.post(url_embarque, {option:32, embarque: embarque, fecha: fecha, idPelador: id_pelador, 
               trabajo: trabajo, pago: pago, concepto:concepto}).then(response =>{
                   //console.log(response.data);
                   if(response.data=="OK1null"){
                       Swal.fire({
                           title: 'Datos registrados',
                           text: 'Se ha registrado un trabajo al bolsero '+id_pelador,
                           icon: 'success',
                           backdrop: false                        
                       });
                       this.listarPeladoresExtras();
                       this.listarPeladores();
                   }else{
                       Swal.fire({
                           title: 'Ocurrio un error',
                           text: 'No se logro realizar el registro',
                           icon: 'error',
                           backdrop: false                        
                       });
                   }
            });
        },
        btnUpdatePeladorExtra: async function(id, idE, pago, trabajo, concepto, idBP){
            var sel1=null, sel2=null;
            if(trabajo==2){
                sel1='selected';
            }else{
                sel2='selected';
            }
            //console.log(trabajo);
                await Swal.fire({
                    title: 'Actualizar Datos',
                    html: '<h4 class="col-sm-12 text-center mt-3 mb-3">Pelador #'+id+'</h4>'+
                    '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Pago</label><div class="col-sm-8"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="pago" value="'+pago+'"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Actividad</label><div class="col-sm-8">'+
                    '<select class="form-control" name="tipo-reg-admin" required id="optionsPrivilegio"><option selected '+sel1+' value="2">Bolsero</option><option '+sel2+' value="1">Otra actividad</option>'+
                    '</select></div></div>'+
                    '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Concepto</label><div class="col-sm-8"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="concepto" value="'+concepto+'"></div></div>',
                    focusConfirm: false,
                    showCancelButton: true,
                    cancelButtonText: 'Cancelar',
                    confirmButtonText: 'Actualizar',
                    cancelButtonColor:'#FF0000',
                    backdrop: false
                }).then((result) => {
                    if(result.value){
                        pago = document.getElementById('pago').value,
                        concepto = document.getElementById('concepto').value,
                        trabajo = document.getElementById('optionsPrivilegio').value

                        this.editarDatosExtra(idE, pago, trabajo, concepto, idBP);
                    }
                });
        },
        btnFinTrabajo(id, idE, idBP){
            Swal.fire({
                title: '¿Está seguro de que desea finalizar este trabajo?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Finalizar',
                backdrop: false
            }).then((result) => {
                if (result.value) {
                    this.finPeladorExtra(id, idE, idBP);
                    //y mostramos un mensaje sobre la eliminación
                  
                }
            })
        },
        finPeladorExtra(id, idE ,idBP){
            axios.post(url_embarque, {option:37,  idE: idE,idBP: idBP}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            title: 'Fin de trabajo',
                            text: 'Trabajo finalizado del trabajador',
                            icon: 'success',
                            backdrop: false                        
                        });
                        this.listarPeladores();
                        this.listarPeladoresExtras();
                        this.listarTrabajadores();
                        this.listarBolserosTodos();
                    }else{
                        Swal.fire({
                            title: 'Ocurrio un error',
                            text: 'No se logro finalizar el trabajo',
                            icon: 'error',
                            backdrop: false                        
                        });
                    }
             });
        },
        editarDatosExtra(idE, pago, trabajo, concepto, idBP){
            axios.post(url_embarque, {option:33, embarque: this.embActual, idBP: idBP, idE:idE,
                trabajo: trabajo, pago: pago, concepto:concepto}).then(response =>{
                   //console.log(response.data);
                   if(response.data=="OK1null"){
                       Swal.fire({
                        title: 'Datos actualizados',
                        text: 'Se actualizó correctamente datos del trabajador',
                        icon: 'success',
                        backdrop: false                         
                       });
                       this.listarPeladoresExtras();
                       this.listarTrabajadores();
                       this.listarPeladores();
                       this.listarBolserosTodos();
                   }else{
                       Swal.fire({
                        title: 'Ocurrio un error',
                        text: 'No se logro actualizar el registro',
                        icon: 'error',
                        backdrop: false                          
                       });
                   }
            });
        },
        btnDeletePeladorExtra (id, idE, pago, idBP, concepto){
            Swal.fire({
                title: 'Se eliminara permanentemente al trabajador '+id+' de los trabajos extras',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Eliminar',
                backdrop: false
            }).then((result) => {
                if (result.value) {
                    this.deletePeladorExtra(id, idE, pago, idBP);
                    //y mostramos un mensaje sobre la eliminación
                  
                }
            })
        },
        deletePeladorExtra(id, idE, pago, idBP){
            axios.post(url_embarque, {option:34, embarque: this.embActual, id: id, idE: idE,idBP: idBP,
                 pago: pago}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            title: 'Datos eliminados',
                            text: 'Se ha eliminado de la base de datos al trabajor: '+id,
                            icon: 'success',
                            backdrop: false                        
                        });
                        this.listarPeladoresExtras();
                        this.listarTrabajadores();
                        this.listarPeladores();
                        this.listarBolserosTodos();
                    }else{
                        Swal.fire({
                            title: 'Ocurrio un error',
                            text: 'No se logro eliminar el registro',
                            icon: 'error',
                            backdrop: false                        
                        });
                    }
             });
        },
        listarPeladoresExtras(){
            axios.post(url_embarque, {option:35, id:this.embActual}).then(response =>{
                this.listaExtras=response.data;
                //console.log(this.listaExtras);
            });
        },
    
    // Fin pelador extra
        async btnModExtra(id, nombre, apellidos, edad, tel, dir, cuenta, actividad, pago, fecha){
            var pago_t=pago;
            const { value: formModExtra } = await Swal.fire({
                title: 'Registrar Bolsero Extra',
                width: 700,
                html: '<div class="form-group row text-white"><label class="col-sm-5 col-form-label text-dark text-right">Nombre</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabajador" value="'+nombre+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellidos</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabajador" value="'+apellidos+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Edad</label><div class="col-sm-5"><input type="number" class="form-control" id="edad" value="'+edad+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Telefono</label><div class="col-sm-5"><input type="text" class="form-control" pattern="[0-9]{0-10}" maxlength="10" id="tel" value="'+tel+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Dirección</label><div class="col-sm-5"><input type="text" class="form-control" id="dir" name="dir-reg-trabajador" value="'+dir+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">No. Cuenta</label><div class="col-sm-5"><input type="text" class="form-control" maxlength="16" id="cuenta" name="cuenta-reg-trabajador" value="'+cuenta+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Trabajo</label><div class="col-sm-5"><input type="text" class="form-control" id="actividad" name="trabajo-reg-actividad" value="'+actividad+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Pago</label><div class="col-sm-5"><input type="number" step="0.1" class="form-control" id="pago" name="pago-reg-trabajador" value="'+pago+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Fecha</label><div class="col-sm-5"><input type="date" class="form-control" id="fecha" name="feha-reg-trabajador" value="'+fecha+'"></div></div>'+
                '<input type="hidden" id="pago_t" name="pago-reg-mod" value="'+pago+'">',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {            
                    return [
                    nombre = document.getElementById('NombreTrabajador').value,
                    apellidos = document.getElementById('apellidoPaterno').value,
                    edad = document.getElementById('edad').value,
                    tel = document.getElementById('tel').value,
                    dir = document.getElementById('dir').value,
                    cuenta = document.getElementById('cuenta').value,
                    actividad = document.getElementById('actividad').value,
                    pago = document.getElementById('pago').value,
                    fecha = document.getElementById('fecha').value,
                    pago_t = document.getElementById('pago_t').value
                    ]
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#NombreTrabajador").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#apellidoPaterno").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#edad").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#tel").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#dir").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#cuenta").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#actividad").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#fecha").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pago_t").addEventListener("keyup", confirmOnEnter);
                }
            });
                if(nombre != "" || apellidos != "" ||
                    edad != 0 || dir !="" || actividad != "" || pago != 0 && formModExtra){
                    this.modBolseroExtra(id, nombre, apellidos, edad, dir, tel, cuenta, actividad, pago, pago_t, fecha);
                }
        },
        modBolseroExtra(id, nombre, apellidos, edad, dir, tel, cuenta, acti, pago, pago_1, fecha){
            axios.post(url_embarque, {option:20, id:id, embarque: this.embActual, nombre: nombre, apellidos: apellidos, edad: edad,
                dir:dir, tel:tel, cuenta: cuenta, acti: acti, pago: pago, pago_1: pago_1, fecha: fecha}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos del Bolsero Modificado',
                            text: 'Se han modificado los datos del Trabajador',
                            backdrop: false
                        });
                        this.listarExtra();
                    }else if(response.data=="ErrorEnGatos"){
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar al Trabajador',
                            backdrop: false
                        });
                    }else{
                        Swal.fire({
                            icon: 'warning',
                            title: 'Cambio no confirmado',
                            text: 'No se modifico el registro',
                            backdrop: false
                        });
                    }
            });
        },
        btnDelExtra(id, pago){
            Swal.fire({
                icon: 'question',
                title: 'Esta seguro de eliminar los datos',
                text: 'Se eliminará permanentemente el registro del trabajador',
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
              if (result.value) {
                axios.post(url_embarque, {option:21, id:id, pago: pago, embarque: this.embActual}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos del Bolsero Eliminados',
                            text: 'Se han eliminado los datos del Trabajador',
                            backdrop: false
                        });
                        this.listarExtra();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar al Trabajador',
                            backdrop: false
                        });
                    }
                });
              }
            });
        },

    //Operaciones de Otros trabajos de Bolseros
        async btnAsignarTrabajo(id){
            var fecha='', pago=0, actividad='';
            const { value: formOtroTrabajo } = await Swal.fire({
                title: 'Asignar Trabajo',
                html: '<h4 class="col-sm-12 text-center mt-3 mb-3">Bolsero #'+id+'</h4>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Pago</label>'+
                    '<div class="col-sm-7"><input type="number" step="0.01" class="form-control" value="0" id="pago" autofocus>'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Trabajo</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="actividad" row="2" value=""/>'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" value="'+this.fecha_dia+'" id="fechaAsistencia">'+
                    '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Asignar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {
                    return[
                        fecha = document.getElementById('fechaAsistencia').value,
                        pago = document.getElementById('pago').value,
                        actividad = document.getElementById('actividad').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#fechaAsistencia").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#actividad").addEventListener("keyup", confirmOnEnter);
                }
            });
            if(pago!=0 && fecha != '' && formOtroTrabajo){
                this.regTrabajoBolsero(id, fecha, pago, actividad, this.embActual);
            }else if(pago==0 && fecha == '' && formOtroTrabajo){
                Swal.fire({
                    title: 'Datos incompletos',
                    text: 'No se completaron los campos',
                    icon: 'warning',
                    backdrop: false
                });
            }else{
                //NO hacer nada
            }
        },
        listarOtrosTrabajos(){
            axios.post(url_embarque, {option:23, id:this.embActual, fecha:this.fecha_dia}).then(response =>{
                //console.log(response.data);
                this.trabajosExtras=response.data;
            });
        },
        async btnModOtroTrab(id, id_bolsero, actividad, fecha, pago, idExtra){
            var pago_f=pago;
            var idE=idExtra;
            const { value: formModTrabajo } = await Swal.fire({
                title: 'Registrar Bolsero Extra',
                html: '<h4 class="col-sm-12 text-center mt-3 mb-3">Bolsero #'+id_bolsero+'</h4>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Pago</label>'+
                    '<div class="col-sm-7"><input type="number" step="0.01" class="form-control" id="pago" value="'+pago+'">'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Trabajo</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="actividad" row="2" value="'+actividad+'"/>'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" value="'+fecha+'" id="fechaAsistencia">'+
                    '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {
                    return [
                    actividad = document.getElementById('actividad').value,
                    pago = document.getElementById('pago').value,
                    fecha = document.getElementById('fechaAsistencia').value
                    ]
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#actividad").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#fechaAsistencia").addEventListener("keyup", confirmOnEnter);
                }
            });
                if(pago != 0 || actividad != '' || fecha != '' && formModTrabajo){
                    this.modBolseroOtroTrabajo(id, idE, id_bolsero, actividad, pago, pago_f, fecha);
                }else{
                    //NO hacer nada
                }
        },
        modBolseroOtroTrabajo(id, idE, id_bolsero, actividad, pago, pago_f, fecha){
            axios.post(url_embarque, {option:24, id:id, idE: idE, embarque: this.embActual, bolsero: id_bolsero, acti: actividad,
                pago: pago, pago_: pago_f, fecha: fecha}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos del Trabajo Modificados',
                            text: 'Se han modificado los datos del Trabajado',
                            backdrop: false
                        });
                        this.listarOtrosTrabajos();
                    }else if(response.data=="ErrorRegistro"){
                        Swal.fire({
                            icon: 'warning',
                            title: 'Cambio no confirmado',
                            text: 'No se logro modificar el registro',
                            backdrop: false
                        });
                    }
            });
        },
        async btnDelOtroTrab(id, pago, idE, fecha){
            Swal.fire({
                icon: 'question',
                title: '¿Desea elimnar el registro?',
                text: 'Eliminar el trabajo al Bolsero '+id,
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    axios.post(url_embarque, {option:25, id:id, idE: idE, pago: pago, 
                        embarque: this.embActual, fec: fecha}).then(response =>{
                        //console.log(response.data);
                        if(response.data=="OK1null"){
                            Swal.fire({
                                icon: 'success',
                                title: 'Datos del Bolsero Eliminados',
                                text: 'Se han eliminado los datos del Trabajador',
                                backdrop: false
                            });
                            this.listarOtrosTrabajos();
                            this.listarAsistentes();
                        }else{
                            Swal.fire({
                                icon: 'error',
                                title: 'Ocurrio un error inesperado',
                                text: 'No se logro registrar al Trabajador',
                                backdrop: false
                            });
                        }
                    });
                }
            })
        },

    //Finalizar Día de Trabajo
        finalizarDia(){
            Swal.fire({
              title: 'Finalizar Día',
              text: "¿Esta seguro que desea finalizar día de trabajo?",
              icon: 'warning',
              showCancelButton: true,
              focusCancel: true,
              confirmButtonColor: '#3085d6',
              cancelButtonColor: '#d33',
              confirmButtonText: 'Finalizar',
              backdrop: false,
            }).then((result) => {
                if (result.value) {
                    axios.post(url_embarque, {option:10, id:this.embActual}).then(response =>{
                        
                        if(this.ventanaNew){
                            this.ventanaNew.close();
                            this.auxVentana='';
                        }

                        /* Recargamos la página */
                        location.reload(true);
                    });
                }
            })
        },
        btnVerResumen(){
            document.getElementById('resumen').style.display='block';

            //console.log(this.fecha_dia);
            //console.log(this.embActual);
            axios.post(url_embarque, {option:30, id:this.embActual, fecha:this.fecha_dia}).then(response =>{
               this.listaResumen=response.data;
               //console.log(response.data);
            });
        },
        finalizarCancelar(){
            document.getElementById('resumen').style.display='none';
        },

    //Añadiendo Bolsas Producidas
        btnAddBolsa(id_pelador, nombre){
            if(this.id_bolsero !=0 && this.id_productor != 0){
                Swal.fire({
                  title: 'Sumar Bolsa al embarque '+this.embActual,
                  text: "Se agregara una bolsa a "+nombre+ " del producto "+this.id_productor,
                  icon: 'question',
                  showCancelButton: true,
                  confirmButtonColor: '#3085d6',
                  cancelButtonColor: '#d33',
                  confirmButtonText: 'Sumar',
                  cancelButtonText: 'Cancelar',
                  showCloseButton: true,
                  backdrop: false
                }).then((result) => {
                    if (result.value) {
                        this.sumarBolsa(this.embActual, id_pelador, this.id_bolsero, this.id_productor);
                    }
                })
            }else{
                Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'Bolsa no registrada',
                    backdrop: false
                })
            }
        },
        cargarBolsasDatos(){
            axios.post(url_embarque,{option:2, id:this.embActual}).then(response =>{
                this.datosEmbarque = response.data;
                this.fechadelDia();
                this.listaBolsasDiarias();
            });
        },
        //PROCEDIMIENTO para añadir Bolsa al embarque, pelador y bolsero
        sumarBolsa(embarque, pelador_id, bolsero_id, productor_id){
            axios.post(url_embarque, {option:11, embarque:embarque, id_p: pelador_id, id_b: bolsero_id,
                id_prod: productor_id, fecha: this.fecha_dia, pagoB: this.pagoBolsero, 
                pagoP: this.pagoPelador, bolsaNo: this.noBolsas, dia: this.diaActual}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK1null"){
                        this.cargarBolsasDatos();
                        this.listarPeladores();
                        this.id_bolsero=0;
                        this.id_productor=0;
                        if(this.ventanaNew){
                            this.ventanaNew=this.auxVentana;
                            this.ventanaNew.location.reload();
                        }
                        Swal.fire({
                            icon: 'success',
                            title: 'Bolsa Registrada',
                            backdrop: false
                        })
                        snd.play();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar el registro',
                            backdrop: false
                        })  
                    }

            });
        },
        async capturaBolsas(idPel){
            var bolsa=0, prod=0;
            const { value: numeroBolsa } = await Swal.fire({
                title: 'Registrar Bolsas',
                html: '<div class="form-group row mt-1">'+
                    '<label for="cantidadBol" class="col-sm-4 col-form-label text-dark text-right">Cant. Bolsas</label>'+
                    '<div class="col-sm-7"><input type="number" step="1" class="form-control" id="cantidadBol" value="'+bolsa+'">'+
                    '</div></div>'+
                    '<div class="form-group row mt-1">'+
                    '<label for="productor" class="col-sm-4 col-form-label text-dark text-right">Productor</label>'+
                    '<div class="col-sm-7"><input type="number" step="1" class="form-control" id="productor" value="'+prod+'"/>'+
                    '</div></div>',
                backdrop: false,
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonColor: '#d33',
                confirmButtonColor: '#3085d6',
                confirmButtonText: 'Registrar',
                cancelButtonText: 'Cancelar',
                preConfirm: () => {
                    return[
                        bolsa = document.getElementById('cantidadBol').value,
                        prod = document.getElementById('productor').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#cantidadBol").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#productor").addEventListener("keyup", confirmOnEnter);
                }
            });
            if(numeroBolsa && bolsa!=0 && prod!=0){
                axios.post(url_embarque, {option:111, embarque: this.embActual, id_p: idPel, fecha: this.fecha_dia, 
                pagoP: this.pagoPelador, bolsaNo: this.noBolsas, bolsas: bolsa, productor: prod }).then(response =>{
                    //console.log(response.data);
                    if(response.data=='OK1null'){
                        this.cargarBolsasDatos();
                        this.listarPeladores();
                        Swal.fire({
                            icon: 'success',
                            title: 'Bolsa(s) Registrada(s)',
                            backdrop: false
                        }) 
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar el registro, compruebe que el trabajador no tenga registrada otra actividad en este momento o que el productor exista',
                            backdrop: false
                        }) 
                    }
                    //console.log(response.data);
                });
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    icon:'warning',
                    mensaje: 'No ha completado los datos corectamente',
                    backdrop: false
                });
            }
        },

    //Obteniendo datos para el tablero
        btnTablero(){
            if(!this.ventanaNew){
                this.ventanaNew=window.open("http://localhost/PLATANERATAB/tablero/"+this.embActual+"/"+this.fecha_dia.replace(/-/g,"/"));

                this.ventanaNew.onbeforeunload=()=>{
                    this.cerrar();
                }
            }
            this.auxVentana=this.ventanaNew;
        },
        cerrar(){
            if(this.ventanaNew){
                //document.getElementById('enviar').style.display = 'none';
                this.ventanaNew.close();
                this.ventanaNew="";
            }
        },
        leer_balanzas(){
            _seft=this;
            $.ajax({
                data: {
                        archivo: "../../platanera/include/serial1.txt"
                    }, 
                url:   '../core/leer_datos.php', //archivo que recibe la peticion
                type:  'POST', //método de envio            
                dataType: "json",
                success: function(response){ //una vez que el archivo recibe el request lo procesa y lo devuelve                
                    var resultado = JSON.parse(JSON.stringify(response));
                    //$("#peso_parcial").html(resultado.peso);
            _seft.peso = parseFloat(resultado.peso);
            //console.log(_seft.peso);
                }
            });
        }
    },
    created: function(){ 
        var self=this;
        setInterval(function(){
            self.leer_balanzas();
        }, 250);
        this.listarProductores();
        this.listarEmbarquesActivos();
        this.listaPagos();    
        this.listarPeladoresExtras();
    },
    computed:{
        search(){
            return this.listaTrabB.filter(
                (listaD) => listaD.id.includes(this.filtro)
            );
        },
        search2(){
            return this.listaTrabP.filter(
                (listaP) => listaP.nombre.includes(this.filtro_2.toUpperCase())
            );
        },
        search3(){
            return this.listaTrabPT.filter(
                (listaPT) => listaPT.id.includes(this.filtro_3)
            );
        },
        fintroBolsas(){
            return this.bolsasDia.filter(
                (bolsasDia) => bolsasDia.nombre.includes(this.filtro_bolsas.toUpperCase())
            );
        }
    }
});


