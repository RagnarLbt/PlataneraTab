$(document).ready(function(){
	/*Mostrar ocultar area de notificaciones*/
	$('.btn-Notification').on('click', function(){
        var ContainerNoty=$('.container-notifications');
        var NotificationArea=$('.NotificationArea');
        if(NotificationArea.hasClass('NotificationArea-show')&&ContainerNoty.hasClass('container-notifications-show')){
            NotificationArea.removeClass('NotificationArea-show');
            ContainerNoty.removeClass('container-notifications-show');
        }else{
            NotificationArea.addClass('NotificationArea-show');
            ContainerNoty.addClass('container-notifications-show');
        }
    });
    /*Mostrar ocultar menu principal*/
    $('.btn-menu').on('click', function(){
    	var navLateral=$('.navLateral');
    	var pageContent=$('.pageContent');
    	var navOption=$('.navBar-options');
    	if(navLateral.hasClass('navLateral-change')&&pageContent.hasClass('pageContent-change')){
    		navLateral.removeClass('navLateral-change');
    		pageContent.removeClass('pageContent-change');
    		navOption.removeClass('navBar-options-change');
    	}else{
    		navLateral.addClass('navLateral-change');
    		pageContent.addClass('pageContent-change');
    		navOption.addClass('navBar-options-change');
    	}
    });
    /*Salir del sistema*/
    $('.btn-exit').on('click', function(){
    	swal({
		  	title: '¿Esta eguro que desea salir del sistema?',
		 	text: "La cuenta de sessión se cerrara...",
		  	type: 'warning',
		  	showCancelButton: true,
		  	confirmButtonText: 'Si, salir',
		  	closeOnConfirm: false
		},
		function(isConfirm) {
		  	if (isConfirm) {
		    	window.location='./vistas/contenido/login-view.php'; 
		  	}
		});
    });
    /*Mostrar y ocultar submenus*/
    $('.btn-subMenu').on('click', function(){
    	var subMenu=$(this).next('ul');
    	var icon=$(this).children("span");
    	if(subMenu.hasClass('sub-menu-options-show')){
    		subMenu.removeClass('sub-menu-options-show');
    		icon.addClass('zmdi-chevron-left').removeClass('zmdi-chevron-down');
    	}else{
    		subMenu.addClass('sub-menu-options-show');
    		icon.addClass('zmdi-chevron-down').removeClass('zmdi-chevron-left');
    	}
    });
    /*Tablas
    $('#tablas').DataTable({
        "searching": false,
        language: {
            processing: "Traitement en cours...",
            search: "Buscar:",
            lengthMenu:    "Mostar _MENU_ elementos",
            info:           "Mostrando de _START_ al _END_ de _TOTAL_ elementos",
            infoEmpty:      "Visualización del elemento 0 a 0 en 0 elementos",
            infoFiltered:   "(filtrado de _MAX_ en total)",
            infoPostFix:    "",
            loadingRecords: "Cargando...",
            zeroRecords:    "No hay elementos para mostrar",
            emptyTable:     "No hay datos disponibles en la tabla",
            paginate: {
                first:      "Inicio",
                previous:   "Anterior",
                next:       "Siguiente",
                last:       "Final"
            }
        }
    });*/
});
(function($){
        $(window).on("load",function(){
            $(".NotificationArea, .pageContent").mCustomScrollbar({
                theme:"dark-thin",
                scrollbarPosition: "inside",
                autoHideScrollbar: true,
                scrollButtons:{ enable: true }
            });
            $(".navLateral-body").mCustomScrollbar({
                theme:"light-thin",
                scrollbarPosition: "inside",
                autoHideScrollbar: true,
                scrollButtons:{ enable: true }
            });
        });
})(jQuery);

/*===============================================
=            Buscar / Filtrar Tablas            =
===============================================*/

$(document).ready(function(){
    $("#filtro").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#tablass tr").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
});

/*=====  End of Buscar / Filtrar Tablas  ======*/

var url_login="http://localhost/PLATANERATAB/ajax/loginAjax.php";
var url_productor="http://localhost/PLATANERATAB/ajax/productorAjax.php";
var url_trabajador="http://localhost/PLATANERATAB/ajax/trabajadoresAjax.php";
var url_embarque="http://localhost/PLATANERATAB/ajax/embarqueAjax.php";
var url_admin="http://localhost/PLATANERATAB/ajax/administradorAjax.php";

const login= new Vue({
    el: '#login',
    data: {
        userName: '',
        userPass: ''
    },
    methods: {
        btnIniciar (){
            console.log(this.userName+" Bienvenido tu contraseña es "+this.userPass);
        },
        btnSalir (){
            Swal.fire({
                title: '¿Esta seguro que desea salir?',
                text: "La sessión será cerrada temporalmente!",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si, Salir',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    this.cerrarSesion();
                }
            })
            console.log("Saliendo..");
        },
        cerrarSesion (){
            /*===================================================================
            =            Eliminar la sesión y redireccionar al Login            =
            ===================================================================*/
            
            
            
            /*=====  End of Eliminar la sesión y redireccionar al Login  ======*/
            
        }
    }
});

const productor= new Vue({
    el: '#productores',
    data: {
        totalRegistros: 0,
        lista:[],
        id: "",
        nombre:"",
        apPat:"",
        apMat:"",
        total:0
    },
    methods:{
        //Botones
        //Boton Registrar
        btnRegistro: async function (){
            const { value: formValues } = await Swal.fire({
                title: 'Registrar Productor',
                html: '<div class="form-group row"><label for="nombre" class="col-sm-4 col-form-label text-dark text-right">Nombre</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreProductor" name="nombre-reg-productor" autofocus></div></div><div class="form-group row"><label for="pago" class="col-sm-4 col-form-label text-dark text-right">Apellido Paterno</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-productor"></div></div><div class="form-group row"><label for="total" class="col-sm-4 col-form-label text-dark text-right">Apellido Materno</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-productor"></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                preConfirm: () => {            
                    return [
                        this.nombre = document.getElementById('NombreProductor').value,
                        this.apPat = document.getElementById('apellidoPaterno').value,
                        this.apMat = document.getElementById('apellidoMaterno').value                    
                    ]
                }
            })
            if(this.nombre == "" || this.apPat == "" || this.apMat == ""){
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Datos no registrados'
                })
            }else {
                this.altaProductor();
                const Toast = Swal.mixin({
                    toast: true,
                    position: 'top',
                    showConfirmButton: false,
                    timer: 2400
                });
                Toast.fire({
                    type: 'success',
                    title: '¡Productor Registrado!',
                    background: '#FFFFFF'
                })
            }
        },
        //Boton Eliminar
        btnDelete: function(id){
            Swal.fire({
                title: '¿Está seguro de borrar el registro: '+id+" ?",         
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Borrar'
            }).then((result) => {
                if (result.value) {
                    this.eliminarProductor(id);
                    //y mostramos un mensaje sobre la eliminación
                    Swal.fire(
                        '¡Eliminado!',
                        'El registro ha sido borrado.',
                        'success'
                        )
                }
            })
        },
        //Boton Actualizar
        btnUpdate: async function(id, nombre, app, apm){
            await Swal.fire({
                title: 'Actualizar Datos',
                html: '<div class="form-group row"><input type="hidden" value="'+id+'" id="id"><label for="nombre" class="col-sm-4 col-form-label text-dark text-right">Nombre</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreProductor" name="nombre-reg-productor" value="'+nombre+'"></div></div><div class="form-group row"><label for="pago" class="col-sm-4 col-form-label text-dark text-right">Apellido Paterno</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-productor" value="'+app+'"></div></div><div class="form-group row"><label for="apellidoMaterno" class="col-sm-4 col-form-label text-dark text-right">Apellido Materno</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-productor" value="'+apm+'"></div></div>',
                focusConfirm: false,
                showCancelButton: true
            }).then((result) => {
                if(result.value){
                    id = document.getElementById('id').value,
                    nombre = document.getElementById('NombreProductor').value,
                    app = document.getElementById('apellidoPaterno').value,
                    apm = document.getElementById('apellidoMaterno').value,

                    this.editarDatos(id,nombre,app,apm);
                    Swal.fire(
                        '¡Actualizado!',
                        'El registro ha sido actualizado.',
                        'success'
                    )
                }
            });
        },
        //PROCEDIMIENTOS
        //Listar Datos
        listarDatos: function (){

            axios.post(url_productor,{option:4}). then(response =>{
                this.lista = response.data;
                //console.log(this.lista);
            });
        },
        //Procedimiento CREAR.
        altaProductor: function(){

            axios.post(url_productor, {option:1, nombre:this.nombre, app:this.apPat, apm:this.apMat }).then(response =>{
                this.listarDatos();
            });        
            this.nombre = "",
            this.apPat = "",
            this.apMat = ""
        },
        //Editar Datos de Productor
        editarDatos: function(id,nombre,app,apm){

            axios.post(url_productor, {option:2, id:id, nombre:nombre, app:app, apm:apm }).then(response =>{
                this.listarDatos();
            });
        },
        //Eliminar Datos de Productor
        eliminarProductor: function(id){
            axios.post(url_productor, { option:3, id:id }).then(response =>{           
                this.listarDatos();
            });
        }
    },
    created: function(){
        this.listarDatos();
    },
    computed: {
        totalRegistrados(){
            this.total = 0;
            for(list of this.lista){
                this.total++;
            }
            return this.total;
        }
    }
});

const trabajador = new Vue({
    el:'#trabajadores',
    data: {
        listaTrabP:[],
        listaTrabB:[],
        id: "",
        nombre: "",
        apPat: "",
        apMat: "",
        tipo: 0,
        totalP: 0,
        totalB: 0
    },
    methods:{
        //Botones
        //Boton Registrar
        btnRegistro: async function (){
            const { value: formValues } = await Swal.fire({
                title: 'Registrar Trabajador',
                html: '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Nombre</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabajador" autofocus></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Paterno</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Materno</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-trabajador"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Puesto de Trabajo</label><div class="col-sm-5"><select class="form-control equipo" name="tipo-reg-trabajador" required id="tipoTrabajador"><option selected value="1">Pelador</option><option value="2">Bolsero</option></select></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                preConfirm: () => {            
                    return [
                        this.nombre = document.getElementById('NombreTrabajador').value,
                        this.apPat = document.getElementById('apellidoPaterno').value,
                        this.apMat = document.getElementById('apellidoMaterno').value,
                        this.tipo = document.getElementById('tipoTrabajador').value
                    ]
                }
            })
            if(this.nombre == "" || this.apPat == "" || this.apMat == ""){
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Datos no registrados'
                })
            }else {
                this.registrarTrabajador();
                const Toast = Swal.mixin({
                    toast: true,
                    position: 'top',
                    showConfirmButton: false,
                    timer: 1200
                });
                Toast.fire({
                    type: 'success',
                    title: '¡Productor Registrado!',
                    background: '#FFFFFF'
                })
            }
        },
        //Boton Actualizar
        btnUpdate: async function(id, nombre, app, apm, tipo){
            p=""; b="";
            if(tipo==1){
                p="selected"; b="hidden";
            }else{
                b="selected"; p="hidden";
            }
            await Swal.fire({
                title: 'Actualizar Datos',
                 html: '<input type="hidden" value="'+id+'" id="id" />'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Nombre</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" name="nombre-reg-trabajador" value="'+nombre+'"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Paterno</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" name="app-reg-trabajador" value="'+app+'"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Materno</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" name="apm-reg-trabajador" value="'+apm+'"></div></div>'+
                    '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Puesto de Trabajo</label><div class="col-sm-5"><select class="form-control equipo" name="tipo-reg-trabajador" required id="tipoTrabajador"><option '+p+' value="1">Pelador</option><option '+b+' value="2">Bolsero</option></select></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Actualizar',
                cancelButtonColor:'#FF0000'
            }).then((result) => {
                if(result.value){
                    id = document.getElementById('id').value,
                    nombre = document.getElementById('NombreTrabajador').value,
                    app = document.getElementById('apellidoPaterno').value,
                    apm = document.getElementById('apellidoMaterno').value,
                    tipo = document.getElementById('tipoTrabajador').value

                    this.editarTrabajador(id,nombre,app,apm,tipo);
                    Swal.fire(
                        '¡Actualizado!',
                        'El registro ha sido actualizado.',
                        'success'
                    )
                }
            });
        },
        btnDelete: function(id, tipo){
            Swal.fire({
                title: '¿Está seguro de borrar el registro: '+id+"?",         
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Borrar'
            }).then((result) => {
                if (result.value) {
                    this.eliminarTrabajador(id, tipo);
                    //y mostramos un mensaje sobre la eliminación
                    Swal.fire(
                        '¡Eliminado!',
                        'El registro ha sido borrado.',
                        'success'
                        )
                }
            })
        },

        //POCEDIMIENTOS
        //Listar Datos
        listarTrabajador: function (){
            axios.post(url_trabajador,{option:4}). then(response =>{
                this.listaTrabP = response.data;
                //console.log(this.listaTrabP);
            });
            axios.post(url_trabajador,{option:5}). then(response =>{
                this.listaTrabB = response.data;
                //console.log(this.listaTrabB);
            });
        },
        //REGISTRAR TRABAJADOR
        registrarTrabajador: function (){
            axios.post(url_trabajador,{option:1, nombre: this.nombre, app: this.apPat, apm: this.apMat, tipo: this.tipo}). then(response =>{
                this.listarTrabajador();
            });
            this.nombre="", this.apPat="", this.apMat="", this.tipo=0
        },
        //EDITAR TRABAJADOR
        editarTrabajador: function(id, nombre, app, apm, tipo){
            axios.post(url_trabajador,{option:2, id: id, nombre: nombre, app: app, apm: apm, tipo: tipo}). then(response =>{
                this.listarTrabajador();
            });
        },
        eliminarTrabajador: function(id,tipo){
            axios.post(url_trabajador,{option:3, id: id, tipo: tipo}). then(response =>{
                this.listarTrabajador();
            });
        }
    },
    created: function(){
         this.listarTrabajador();
    },
    computed:{
        totalRegistradosP(){            
            this.totalP = 0;
            for(list of this.listaTrabP){
                this.totalP++;
            }
            return this.totalP;
        },
        totalRegistradosB(){
            this.totalB = 0;
            for(list of this.listaTrabB){
                this.totalB++;
            }
            return this.totalB;
        }
    }
});

const embarque = new Vue({
    el: '#embarques',
    data: {
    //Datos generales
        listaEmbarques: [], /* Lista de Embarques sin finalizar */
        id: 0, /* Datos para crear un embarque */
        fecha: '', /*  Datos para crear un embarque */
        selected: 0, /* Embarque SELECCIONADO*/
        embActual: '', /* Embarque SELECCIONADO - VAR. AUX */
        datosEmbarque: [], /* Datos generales del embarque actual */
        listaTrabP:[],
        listaTrabB:[], /* Lista de Trabajadores General*/
        listaProductor: [], /* Lista de Trabajadores del día*/
    
    // Datos obtenidos del embarque seleccionado
        noBolsas: 0,
        fecha_dia: '',
        fechaAsis: '',
    
    // Datos para el registro de fruta
        idProd: 0,
        peso: '',
        listaPesos: [],
        listaFruta: [],
    
    //Datos de los asistentes y producción diaria */
        peladoresAsistentes: [],
        bolserosAsistentes: [],
        id_bolsero:0,
        id_productor: 0,
    
    //Filtrado de Trabajadores 
        filtro: '',
        filtro_2: '',
    
    //Fializar embarque
        fecha_fin: '',
        contenedor: '',
        sello:'',
        temperatura: 0,
        matricula: '',
        conductor: ''
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
                preConfirm: () => {        
                    return [
                        this.id = document.getElementById('NumeroEmbarque').value,
                        this.fecha = document.getElementById('FechaEmbarque').value
                    ];
                }
            })
            if(this.id == 0 || this.fecha == ""){
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Embarque no registrado'
                })
            }else {
                this.crearEmbarque();
                const Toast = Swal.mixin({
                    toast: true,
                    position: 'top',
                    showConfirmButton: false,
                    timer: 2400
                });
                Toast.fire({
                    type: 'success',
                    title: 'Embarque Creado!',
                    background: '#FFFFFF'
                })
            }
        },
        //Procedimiento CREAR.
        crearEmbarque: function(){
            //console.log(this.id+" "+this.fecha);
            axios.post(url_embarque, {option:1, id:this.id, fecha:this.fecha}).then(response =>{
                this.listarEmbarquesActivos();
            });
            this.id = 0,
            this.fecha = ""
        },

    //Finalizar Embarque
        btnFinalizarEmbarque(){
            Swal.fire({
              title: 'Finalizar Embarque',
              text: "¿Esta seguro que desea finalizar el Embarque "+this.embActual+"?",
              type: 'warning',
              showCancelButton: true,
              confirmButtonColor: '#3085d6',
              cancelButtonColor: '#d33',
              confirmButtonText: 'Finalizar',
              cancelButtonText: 'Cancelar'
            }).then((result) => {
              if (result.value) {
                if(this.embActual != '' && this.fecha_fin != '' && this.contenedor != '' && this.sello != ''
                    && this.matricula != '' && this.temperatura != 0 && this.conductor != ''){
                    axios.post(url_embarque, {option:12, embarque:this.embActual, fecha:this.fecha_fin, 
                    contenedor: this.contenedor, sello: this.sello, matricula: this.matricula, 
                    temperatura: this.temperatura, conductor: this.conductor}).then(response =>{
                        /* Recargamos la página */
                        location.reload(true);
                    });
                }else{
                   Swal.fire({
                      title: 'Datos incompletos',
                      text: "Complete todos los campos",
                      type: 'error',
                   }); 
                }
              }
            })
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
            axios.post(url_trabajador,{option:4}). then(response =>{
                this.listaTrabP = response.data;
                //console.log(this.listaTrabP);
            });
            axios.post(url_trabajador,{option:5}). then(response =>{
                this.listaTrabB = response.data;
                //console.log(this.listaTrabB);
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
            axios.post(url_embarque, {option:8, embarque:this.embActual, fechaDia:this.fecha_dia}).then(response =>{
                this.peladoresAsistentes= response.data;
                //console.log(this.peladoresAsistentes);
            });
            axios.post(url_embarque, {option:9, embarque:this.embActual, fechaDia:this.fecha_dia}).then(response =>{
                this.bolserosAsistentes= response.data;
            });
        },
        //PROCEDIMIENTO para calcular la fecha del día actual
        fechadelDia (){
            this.fecha_dia = '';
            for(dat of this.datosEmbarque){
                if(dat.feha_inicio != ''){
                    //this.fecha_dia=new Date(dat.fecha_inicio);
                    this.fecha_dia=(dat.fecha_inicio + dat.dia_actual);
                }
                    //dat.fecha_dia.setDate(dat.fecha_dia.getDate() + dat.dia_actual); }
            }
            this.fecha_fin=this.fecha_dia;
        },
    
    //Botones y Procedimientos para obtener los datos actuales de un embarque
        /* Boton para obtener todos los datos del embarque seleccionado */
        btnCargarDatos (){
            if(this.selected != 0 && this.selected != 'Sin datos...'){
                this.embActual = this.selected;
                this.buscardatosEmbarque(this.embActual);
            }else{
                Swal.fire({
                    type: 'error',
                    title: 'Dato no valido',
                    text: 'Selecciones un Número de Embarque'
                });
            }
        },
        buscardatosEmbarque(embarque){
            axios.post(url_embarque,{option:2, id:embarque}).then(response =>{
                this.datosEmbarque = response.data;
                this.fechadelDia();
                this.listaFutas();
                this.listarAsistentes();
            });
        },
        listaFutas (){
            axios.post(url_embarque,{option:7, id:this.embActual}). then(response =>{
                this.listaFruta = response.data;
                //console.log(this.listaFruta);
            });
        },

    //Operaciones de Frutas en un embarque
        /* Registro de Fruta */
        async btnRegFruta (){
            const { value: formFruta } = Swal.fire({
                title: 'Confirme para registrar en el Embarque '+this.embActual,
                text: "Para registrar la fruta confirme",
                type: 'question',
                showCancelButton: true,
                confirmButtonColor: '#2DB930',
                cancelButtonColor: '#FF0000',
                confirmButtonText: 'Confirmar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    /* Llamada del procedimiento para registrar */
                    this.registroFruta(this.idProd, this.peso, this.pago, this.total, this.embActual, this.fecha_dia);
                    this.idProd= 0, this.peso= 0, this.pago= 0, this.total= 0;
                    /* Aletra de confirmación */
                    Swal.fire(
                        'Registrado',
                        'La fruta se ha registrado al embarque',
                        'success'
                        );
                    }
                })
        },
        pesoFruta (idProd, peso){
            //console.log(' - '+peso+' - '+idProd);
            if( (idProd != 0) && (peso != '')){
                Swal.fire({
                    html: '<div class="d-flex justify-content-center"><div id="my_camera"></div></div>',
                    focusConfirm: true,
                    showCloseButton: true,
                    allowOutsideClick:false,
                    allowEscapeKey: true,
                    allowEnterKey: false,
                    confirmButtonText:'<i class="zmdi zmdi-camera text-white"></i>&nbsp;Capturar Foto',
                    confirmButtonColor: "#0CAF1B",
                    cancelButtonText:'Cancelar',
                    width: '40%',
                    grow: 'column'
                }).then((result) => {
                    if (result.value) {
                        // actually snap photo (from preview freeze) and display it
                        Webcam.snap( function(data_uri) {
                            this.registroFruta(idProd, peso, this.embActual, this.fecha_dia, data_uri);
                        });                        
                    }
                });
                Webcam.set({
                    width: 512,
                    height: 384,
                    dest_width: 512,
                    dest_height: 384,
                    image_format: 'png',
                    jpeg_quality: 90,
                    force_flash: false
                });
                Webcam.attach( '#my_camera' );
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    type: 'error',
                    text: 'Ingrese el Productor y el Peso antes de capturar la Foto.'
                });
            }
            console.log(this.listaPesos);
        },
        /* PROCEDIMIENTO para el Registro de Futa */
        registroFruta (prod, peso, embarque, fecha, img){
            axios.post(url_embarque, {option:6, id:prod, peso: peso, pago:pago, total:total, embarque:embarque, fecha:fecha, img: img}).then(response =>{
                this.listaFutas();
                //console.log(prod+' '+peso+' '+pago+' ');
            });
        },

    //Asistencia de Bolseros
        /* Asistencia del Día */
        async btnAsistencia (id, tipo){
            /* Obtener la fecha de Asistencia y Reggistrar en la BD*/
            const { value: formAsistencia } = await Swal.fire({
                title: 'Asistencia al Embarque ' +this.embActual,
                html: '<div class="form-group row mt-1">'+
                    '<label for="numero" class="col-sm-4 col-form-label text-dark text-right">Fecha</label>'+
                    '<div class="col-sm-7"><input type="date" class="form-control" value="'+this.fecha_dia+'" id="fechaAsistencia" autofocus>'+
                    '</div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                preConfirm: () => {
                    return [
                        this.fechaAsis = document.getElementById('fechaAsistencia').value
                    ];
                }
             });
             if (this.fechaAsis == "") {
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Asistencia no registrada'
                })
             } else {
                /* Registrar Asistencia en la BD */
                let row = this.regAsistencia(this.embActual, this.fechaAsis, tipo, id);
                if(row.length != 0 ){
                    Toast.fire({
                        type: 'success',
                        title: 'Asistencia Guardada',
                        background: '#FFFFFF'
                    })
                }else{
                    Swal.fire({
                        type: 'error',
                        title: 'Datos duplicados',
                        text: 'Asistencia no registrada, el trabajador ya fue registrado anteriormente'
                    })
                }

                this.fechaAsis='';
             }
        },
        /* PROCEDIMIENTO de Registro de Asistencia */
        regAsistencia (noEmbarque, fecha, tipo, id){
            let row=[];
            //console.log(this.id+" "+this.fecha);
            axios.post(url_embarque, {option:5, embarque: noEmbarque,fechaDia: fecha, tipo: tipo, id: id}).then(response =>{
                row=response.data;
                //console.log(response.data);
                this.listarAsistentes();
            });
            console.log(row);
            return row;
        },
        //Finalizar Día de Trabajo
        finalizarDia(){
            Swal.fire({
              title: 'Finalizar Día',
              text: "¿Esta seguro que desea finalizar día de trabajo?",
              type: 'warning',
              showCancelButton: true,
              confirmButtonColor: '#3085d6',
              cancelButtonColor: '#d33',
              confirmButtonText: 'Finalizar'
            }).then((result) => {
              if (result.value) {
                axios.post(url_embarque, {option:10, id:this.embActual}).then(response =>{
                    /* Recargamos la página */
                    location.reload(true);
                });
              }
            })
        },

    //Añadiendo Bolsas Producidas
        btnAddBolsa(id_pelador, nombre){
            if(this.id_bolsero !=0 && this.id_productor != 0){
                Swal.fire({
                  title: 'Sumar Bolsa al embarque '+this.embActual,
                  text: "Se agregara una bolsa a "+nombre+ "del producto "+this.id_productor,
                  type: 'question',
                  showCancelButton: true,
                  confirmButtonColor: '#3085d6',
                  cancelButtonColor: '#d33',
                  confirmButtonText: 'Sumar'
                }).then((result) => {
                    if (result.value) {
                        this.sumarBolsa(this.embActual, id_pelador, this.id_bolsero, this.id_productor);
                    }
                })
            }else{
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Asistencia no registrada'
                })
            }
        },
        //PROCEDIMIENTO para añadir Bolsa al embarque, pelador y bolsero
        sumarBolsa(embarque, pelador_id, bolsero_id, productor_id){
            axios.post(url_embarque, {option:11, embarque:embarque, id_p: pelador_id, id_b: bolsero_id,
                id_prod: productor_id, fecha: this.fecha_dia}).then(response =>{
                this.buscardatosEmbarque(this.embActual);
            });
                this.id_bolsero=0;
                this.id_productor=0;
        }

    },
    created: function(){ 
        this.listarTrabajadores();
        this.listarProductores();
        this.listarEmbarquesActivos();
    },
    computed:{
        search(){
            return this.listaTrabB.filter(
                (listaD) => listaD.id.includes(this.filtro)
            );
        },
        search2(){
            return this.listaTrabP.filter(
                (listaP) => listaP.id.includes(this.filtro_2)
            );
        }
    }
});

const admin = new Vue({
    el: '#usuarios',
    data:{
        lista:[],
        id:0,
        user:'',
        pass1:'',
        pass2:'',
        clave:'',
        nombre:'',
        apellidos:'',
        genero:'',
        tipo: 0
    },
    methods:{
        async btnRegistro (){
            const{ value:formValues}=await Swal.fire({
                title: 'Registrar Usuario',
                html: '<div class="form-group row">'+
                '<label for="nombre" class="col-sm-4 col-form-label text-dark text-right">Nombre</label>'+
                '<div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreAdmin" name="nombre-reg-admin"></div></div>'+
                '<div class="form-group row"><label for="pago" class="col-sm-4 col-form-label text-dark text-right">Apellidos</label><div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidosAdmin" name="ap-reg-admin"></div></div><div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Genero:</label><div class="form-check form-check-inline col-sm-7">&nbsp;<input class="form-check-input" type="radio" value="Fem" name="optionsGenero" id="fem" checked><label class="form-check-label" for="fem">Femenino</label>&nbsp;<input class="form-check-input" type="radio" value="Masc" name="optionsGenero" id="msc"><label class="form-check-label" for="msc">Masculino</label></div></div><div class="form-group row"><label for="userAdmin" class="col-sm-4 col-form-label text-dark text-right">User Name</label><div class="col-sm-7"><input type="text" placeholder="Escriba un nombre de usuario" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="userAdmin" name="user-reg-admin"></div></div><div class="form-group row"><label for="pass1" class="col-sm-4 col-form-label text-dark text-right">Constraseña</label><div class="col-sm-7"><input type="password" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="pass1" name="pass1-reg-admin"></div></div><div class="form-group row"><label for="pass2" class="col-sm-4 col-form-label text-dark text-right">Contraseña*</label><div class="col-sm-7"><input type="password" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="pass2" name="pass2-reg-admin" placeholder="Escriba su contraseña nuevamente"></div></div><div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Privilegios:</label><div class="form-check form-check-inline col-sm-7">&nbsp;<input class="form-check-input" type="radio" value="1" name="optionsPrivilegio" id="adm" checked><label class="form-check-label" for="adm">Administrador</label>&nbsp;<input class="form-check-input" type="radio" value="2" name="optionsPrivilegio" id="cp"><label class="form-check-label" for="cp">Captura</label></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                preConfirm: () => {            
                    return [
                        this.nombre = document.getElementById('NombreAdmin').value,
                        this.apellidos = document.getElementById('apellidosAdmin').value,
                        this.genero= document.querySelector('input[name = "optionsGenero"]:checked').value,
                        //this.genero = document.getElementsByName('optionsGenero').value,   
                        this.user = document.getElementById('userAdmin').value,
                        this.pass1 = document.getElementById('pass1').value,
                        this.pass2 = document.getElementById('pass2').value,
                        this.tipo = document.querySelector('input[name = "optionsPrivilegio"]:checked').value
                    ]
                }
            })
            //console.log(this.pass1+" "+this.pass2);
            if(this.nombre == "" || this.apellidos == "" || this.genero == ""|| this.user == ""|| this.pass1 == ""|| this.pass2 == ""|| this.tipo == ""){
                Swal.fire({
                    type: 'warning',
                    title: 'Datos incompletos',
                    text: 'Datos no registrados'
                })
            }else {
                if (this.pass1 != this.pass2){
                    Swal.fire({
                        type: 'warning',
                        title: 'Contraseñas incorrectas',
                        text: 'Las contraseñas no coinciden, datos no registrados'
                    })
                }else{
                    this.clave = this.pass1;
                    this.altaUsuario();
                    const Toast = Swal.mixin({
                            toast: true,
                            position: 'top',
                            showConfirmButton: false,
                            timer: 2400
                    });
                    Toast.fire({
                        type: 'success',
                        title: '¡Usuario Registrado!',
                        background: '#FFFFFF'
                    })

                }
            }
        },
        //Procedimientos
        listaUsuarios: function(){
            axios.post(url_admin,{option:3}). then(response =>{
                this.lista = response.data;
                //console.log(this.lista);
            });
        },
        altaUsuario: function(){
            axios.post(url_admin, {option:1, nombre:this.nombre, apellidos:this.apellidos,
                genero:this.genero, user:this.user, clave:this.clave, tipo:this.tipo }).then(response =>{
                this.listaUsuarios();
            });
            this.nombre = '',
            this.apellidos = '',
            this.genero = '',
            this.user = '',
            this.pass1 = '',
            this.pass2 = '',
            this.clave = '',
            this.tipo = 0
        },
        deleteUsuario: function(){
            axios.post(url_admin, { option:2, id:id }).then(response =>{           
                this.listarDatos();
            });
        }
    },
    created: function(){
        this.listaUsuarios();
    }
});
