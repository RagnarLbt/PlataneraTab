const update = new Vue({
    el: '#actu',
    data: {
    //Generales
        listaEmbarques: [], /* Lista de Embarques finalizados */
        listaEmbarqueActivo: [], /* Lista de Embarques sin finalizar */
        selected: 0, /* Embarque SELECCIONADO*/
        embActual:'', /* Embarque SELECCIONADO - VAR. AUX */
    //Productores
        productores:[],
        totalesProd:[],
        pagoF:0,
        fert:0,
        noPFer:0,
        fung:0,
        noPFun:0,
        prest:0,
        noPPre:0,
        afert:0,
        afung:0,
        aprest:0,
    
    //Planilla Toston
        listaTostonTodos:[],
        listaToston:[],
        listaTotalT:[],
        idToston:0,
        id:0,
        nombreT:'',
        cantidadT:0,
        a:0,
        b:0,
        c:0,
        d:0,
        e:0,

    //Bolseros
        listaBo:[],
        listaToB:[],
        idBolsero:0,
        nombreBolsero:'',
        pagoBolsero:0,
        listaBolT:[],

    //Gastos
        datosGastos: [],
        idGasto: 0,
        listGastos:[], /* Listas de los gastos de la BD */
        listaGastosTipo: [],
        //Valores para registro
        cantidad: 0,
        concepto: '',
        kilos_bolsas:0,
    //Cuentas
    //Registro Dolares
        concepto:'', 
        ingreso:0,
        egreso:0,
        taza: 0,
        listaDolares:[],
        listaT:[],
    //Registro de Pesos
        conceptoP: '',
        ingresoP:0,
        egresoP:0,
        listaPesos:[],
        listaTP:[],
    //Registro cuenta en Bolsas
        conceptoB: '',
        ingresoB:0,
        egresoB:0,
        listaBolsas: [],
        listaTB:[],
    //Resumen
        listaR:[],

        selec:0,
        listaTrabT:[],

    },
    methods: {
        btnCargarDatos(){
            //Embarque
            this.embActual = this.selected;
            //Productores
            this.listarProductores();
            this.totalesProductores();
            //Planilla
            this.listaTostonTodo();
            this.listarToston();
            this.listarTotalT();
            //Bolseros
            this.listaBolserosTodo();
            this.listaBolseros();
            this.listaTBolseros();
            //Gastos
            this.listaTipoGastos();
            this.buscarGastosEmbarque(this.embActual);
            this.listarGastosEmbarque(this.embActual);
            //Cuentas
            this.listaD(this.embActual);
            this.listaP(this.embActual);
            this.listaB(this.embActual);
            this.listaTotal();
            this.listaTotalP();
            this.listaTotalB();
            this.mostrarR();
        },
        listarEmbarquesActivos (){
            axios.post(url_update,{option:100}).then(response =>{
                this.listaEmbarqueActivo = response.data;
            });
            axios.post(url_update,{option:1}).then(response =>{
                this.listaEmbarques = response.data;
            });
        },
    //Productores
        listarProductores(){
            axios.post(url_update,{option:2,id:this.embActual }).then(response =>{
                this.productores = response.data;
            });
        },
        totalesProductores(){
            axios.post(url_update,{option:4,id:this.embActual }).then(response =>{
                this.totalesProd = response.data;
            });
        },
        async btnActualizar(idFruta, idProdFru, kilos, pago, fung, ferti, prest, afung, aferti, aprest, noPFun, noPFer, noPPre){
            const { value: actProductor } = await Swal.fire({
                title: "Actualizar Registro",
                html: '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Pago Fruta</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="pago" value="'+pago+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Fungicida</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="fung" value="'+fung+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">N. Pagos Fun.</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="noPFun" value="'+noPFun+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Fertilizante</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="ferti" value="'+ferti+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">N. Pagos Fer.</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="noPFer" value="'+noPFer+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Prestamo</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="prest" value="'+prest+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">N. Pagos Pres.</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="noPPre" value="'+noPPre+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">A. Fungicida</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="afung" value="'+afung+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">A. Fertilizante</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="aferti" value="'+aferti+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">A. Prestamo</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="aprest" value="'+aprest+'">'+
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
                        this.pagoF = document.getElementById('pago').value,
                        this.fung = document.getElementById('fung').value,
                        this.noPFun = document.getElementById('noPFun').value,
                        this.fert = document.getElementById('ferti').value,
                        this.noPFer = document.getElementById('noPFer').value,
                        this.prest = document.getElementById('prest').value,
                        this.noPPre = document.getElementById('noPPre').value,
                        this.afung = document.getElementById('afung').value,
                        this.afert = document.getElementById('aferti').value,
                        this.aprest = document.getElementById('aprest').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#pago").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#fung").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#ferti").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#prest").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#afung").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#aferti").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#aprest").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#noPFun").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#noPPre").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#noPFer").addEventListener("keyup", confirmOnEnter);
                }
            })
            if(actProductor && this.pagoF!=0){
                if( (this.fung>0 && this.noPFun>0) || (this.fung==0 && this.noPFun==0)  ){
                    if( (this.fert>0 && this.noPFer>0) || (this.fert==0 && this.noPFer==0)  ){
                        if( (this.prest>0 && this.noPPre>0) || (this.prest==0 && this.noPPre==0)  ){
                            axios.post(url_update,{option:5, embarque:this.embActual, idFruta:idFruta, idPF:idProdFru, kilos:kilos, pagoFruta:pago, 
                            fungicida:fung,  fertilizante:ferti, prestamo:prest,  
                            abonoFun:afung, abonoFer: aferti, abono_prestamo:aprest, pagoFruNew: this.pagoF,
                            fungicidaNew: this.fung, fertilizanteNew: this.fert, prestamoNew: this.prest,
                            aFunNew: this.afung, aFerNew: this.afert, aPresNew: this.aprest, 
                            noPFun: noPFun, noPFer: noPFer, noPPre: noPPre,
                            noPFunNew: this.noPFun, noPFerNew: this.noPFer, noPPreNew: this.noPPre}).then(response =>{
                                //console.log(response.data);
                                if(response.data=='OK'){
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Datos Actualizados',
                                        text: 'Se han guardado los cambios',
                                        backdrop: false
                                    });
                                    this.listarProductores();
                                    this.totalesProductores();
                                    //this.cunetaListas();
                                }else{
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Ocurrio un error inesperado',
                                        text: 'No se logro realizar la modificación',
                                        backdrop: false
                                    });
                                }
                            });
                        }else{
                            Swal.fire({
                                title: 'Datos incompletos',
                                icon: 'warning',
                                text: 'Debe ingresar una No. de Pagos y una cantidad de Prestamo',
                                backdrop:false
                            });
                        }
                    }else{
                        Swal.fire({
                            title: 'Datos incompletos',
                            icon: 'warning',
                            text: 'Debe ingresar una No. de Pagos y una cantidad de Prestamo',
                            backdrop:false
                        }); 
                    }
                }else{
                    Swal.fire({
                        title: 'Datos incompletos',
                        icon: 'warning',
                        text: 'Debe ingresar una No. de Pagos y una cantidad de Prestamo',
                        backdrop:false
                    });
                }
            }else if(this.pagoF==0 && actProductor){
                Swal.fire({
                    title: 'Datos incompletos',
                    icon: 'warning',
                    text: 'Debe ingresar una cantidad de Pago de Fruta',
                    backdrop:false
                });
            }
        },
    //Planilla Toston
        listaTostonTodo(){
            axios.post(url_trabajador,{option:7}). then(response =>{
                this.listaTrabT = response.data;
            });
        },
        listarToston(){
            axios.post(url_update,{option:3,id:this.embActual }).then(response =>{
                this.listaToston = response.data;
               // console.log(response.data);
           });
        },
        listarTotalT(){
            axios.post(url_update,{option:7,id:this.embActual }).then(response =>{
                this.listaTotalT = response.data;
              // console.log(response.data);
          });
        },
        btnRegToston(){
            if(this.selec!=0){
                this.idToston=this.selec
                Swal.fire({
                    title: 'Registro a planilla del embarque',
                    text: 'Se registrará al trabajador:  '+this.selec+'de planilla al embarque '+this.embActual,
                    icon: 'warning',
                    showCancelButton:true,
                    confirmButtonText: 'Registrar',
                    cancelButtonText: 'Cerrar',
                    backdrop: false,
                    confirmButtonColor:'#40B340',
                    cancelButtonColor:'#FF0000',
                }).then((result) => {
                    if (result.value) {
                        axios.post(url_update, {option:16, id:this.idToston, embarque: this.embActual}).then(response=>{
                          if(response.data=="OK1null"){
                            Swal.fire({
                              title: 'Registrado',
                              text: 'Registro realizado satisfactoriamente',
                              icon: 'success',
                              backdrop: false
                          });
                            this.listarToston();
                            this.listarTotalT();
                        }else{
                            Swal.fire({
                              title: 'Trabajador no registrado',
                              text: 'El trabajador ya está registrado en la base de datos',
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
        async btnToston (idToston, a, b, c, d, e ){
            await Swal.fire({
                title: 'Actualizar datos'+idToston,
                html: '<input type="hidden" value="'+idToston+'" id="idToston" />'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día A</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="a" value="'+a+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día B</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="b" value="'+b+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día C</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="c" value="'+c+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día D</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="d" value="'+d+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día E </label><div class="col-sm-5"><input type="number" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="e" value="'+e+'"></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Actualizar',
                cancelButtonColor:'#FF0000',
                backdrop: false
            }).then((result) => {
                if(result.value){

                  a = document.getElementById('a').value,
                  b = document.getElementById('b').value,
                  c = document.getElementById('c').value,
                  d = document.getElementById('d').value,
                  e = document.getElementById('e').value,

                  this.updateToston(idToston,a,b,c,d,e);

              }
          });
        },
        btnEliminarToston(idToston){
            Swal.fire({
                title: 'Se eliminaran los pagos al trabajador '+idToston,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Eliminar',
                backdrop: false
            }).then((result) => {
                if (result.value) {
                  this.deleteToston(idToston);
              }
          })
        },
        updateToston(idToston,a,b,c,d,e){
            axios.post(url_update,{option:6, id:this.embActual , idP:idToston, a:a, b:b, c:c, d:d, e:e}).then(response =>{
                if(response.data=="OK"){
                    Swal.fire({
                        title: '¡Actualizado!',
                        text: 'El registro ha sido actualizado.',
                        icon: 'success',
                        backdrop: false
                    });
                    this.listarToston();
                    this.listarTotalT();
                    this.listaBolseros();
                    this.listaTBolseros();
                    this.listarGastosEmbarque(this.embActual);
                    this.buscarGastosEmbarque(this.embActual);
                    this.listaP(this.embActual);
                    this.listaB(this.embActual);
                    this.listaTotalP();
                    this.listaTotalB();
                    this.mostrarR();
                }else{
                    Swal.fire({
                        title: 'Ocurrio un error inesperado',
                        text: 'No se lograron actualizar los datos',
                        icon: 'error',
                        backdrop: false
                    });
                }
            });
        },
        deleteToston(idToston){
            axios.post(url_update, {option:14, embarque: this.embActual, idToston: idToston}).then(response =>{
                if(response.data=="OK1null"){
                   Swal.fire({
                     title: 'Datos eliminados',
                     text: 'Se han eliminado los pagos del trabajador : '+idToston,
                     icon: 'success',
                     backdrop: false                        
                 });
                   this.listarToston();
                   this.listarTotalT();
                   this.listaBolseros();
                   this.listaTBolseros();
                   this.listarGastosEmbarque(this.embActual);
                   this.buscarGastosEmbarque(this.embActual);
                   this.listaP(this.embActual);
                   this.listaB(this.embActual);
                   this.listaTotalP();
                   this.listaTotalB();
                   this.mostrarR();
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
    //Bolseros
        listaBolserosTodo(){
            axios.post(url_trabajador,{option:5}). then(response =>{
                this.listaBolT = response.data;
            });
        },
        listaBolseros(){
            axios.post(url_update,{option:8, id:this.embActual}).then(response =>{
                this.listaBo= response.data;
                //console.log(response.data);
            });
        },
        listaTBolseros(){
            axios.post(url_update,{option:9, id:this.embActual}).then(response =>{
                this.listaToB= response.data;
                //console.log(response.data);
            });
        },
        btnRegBolsero(){
            if(this.selec!=0){
                this.idBolsero=this.selec
                Swal.fire({
                  title: 'Registro a bolseros del embarque',
                  text: 'Se registrará al trabajador:  '+this.selec+' al embarque '+this.embActual,
                  icon: 'warning',
                  showCancelButton:true,
                  confirmButtonText: 'Registrar',
                  cancelButtonText: 'Cerrar',
                  backdrop: false,
                  confirmButtonColor:'#40B340',
                  cancelButtonColor:'#FF0000',
                }).then((result) => {
                    if (result.value) {
                        axios.post(url_update, {option:18, id:this.idBolsero, embarque: this.embActual}).then(response=>{
                            if(response.data=="OK1null"){
                                Swal.fire({
                                    title: 'Registrado',
                                    text: 'Registro realizado satisfactoriamente',
                                    icon: 'success',
                                    backdrop: false
                                });
                                this.listaBolseros();
                                this.listaTBolseros();
                            }else{
                                Swal.fire({
                                  title: 'Trabajador no registrado',
                                  text: 'El trabajador ya está registrado en la base de datos',
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
        async btnUpdateB(idBolsero,  a, b, c, d, e ){
            await Swal.fire({
                title: 'Actualizar Datos',
                html: '<input type="hidden" value="'+idBolsero+'" id="idBolsero" />'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día A</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="a" value="'+a+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día B</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="b" value="'+b+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día C</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="c" value="'+c+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día D</label><div class="col-sm-5"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="d" value="'+d+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Día E </label><div class="col-sm-5"><input type="number" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="e" value="'+e+'"></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Actualizar',
                cancelButtonColor:'#FF0000',
                backdrop: false
            }).then((result) => {
                if(result.value){

                  a = document.getElementById('a').value,
                  b = document.getElementById('b').value,
                  c = document.getElementById('c').value,
                  d = document.getElementById('d').value,
                  e = document.getElementById('e').value,

                  this.updateBolsero(idBolsero,a,b,c,d,e);
              }
          });
        },
        btnDeleteBolsero(idBolsero){
            Swal.fire({
                title: 'Se eliminaran los pagos al trabajador '+idBolsero,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Eliminar',
                backdrop: false
            }).then((result) => {
                if (result.value) {
                  this.deleteBolsero(idBolsero);
              }
          })
        },
        updateBolsero(idBolsero,a,b,c,d,e){
            axios.post(url_update,{option:10,embarque:this.embActual ,idBolsero:idBolsero, a:a, b:b, c:c, d:d, e:e }).then(response =>{
                console.log(response.data);
                if(response.data=="OK"){
                    Swal.fire({
                        title: '¡Actualizado!',
                        text: 'El registro ha sido actualizado.',
                        icon: 'success',
                        backdrop: false
                    });
                    this.listaBolseros();
                    this.listaTBolseros();
                    this.listarGastosEmbarque(this.embActual);
                    this.buscarGastosEmbarque(this.embActual);
                    this.listaP(this.embActual);
                    this.listaB(this.embActual);
                    this.listaTotalP();
                    this.listaTotalB();
                    this.mostrarR();
                }else{
                    Swal.fire({
                        title: 'Ocurrio un error inesperado',
                        text: 'No se lograron actualizar los datos',
                        icon: 'error',
                        backdrop: false
                    });
                }
            });
        },
        deleteBolsero(idBolsero){
            axios.post(url_update, {option:17, embarque: this.embActual, idBolsero: idBolsero}).then(response =>{
                if(response.data=="OK1null"){
                   Swal.fire({
                     title: 'Datos eliminados',
                     text: 'Se han eliminado los pagos del trabajador : '+idBolsero,
                     icon: 'success',
                     backdrop: false                        
                 });
                   this.listaBolseros();
                   this.listaTBolseros();
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
    //Gastos del embarque
        //Listar tipos de gastos
        listaTipoGastos(){
            axios.post(url_gastos,{option:3}).then(response =>{
                this.listGastos = response.data;
            });
        },
        buscarGastosEmbarque(embarque){
            axios.post(url_gastos,{option:2, id:embarque}).then(response =>{
                this.datosGastos = response.data;
            });
        },
        //Obtener lista de gastos que se han realizado en el embarque seleccionado
        listarGastosEmbarque(id){
            axios.post(url_gastos,{option:5, id:id, con: 1}).then(response =>{
                this.listaGastosTipo = response.data;
            });
        },
        //Registrar Gasto
        btnResgGasto (){
            if(this.idGasto != 0 && this.cantidad != 0){
                Swal.fire({
                    title: 'Registrar Gasto',
                    text: "¿Esta seguro que desea registrar el gasto en el Embarque "+this.embActual+"?",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Registrar',
                    cancelButtonText: 'Cancelar',
                    backdrop: false
                }).then((result) => {
                    if (result.value) {
                     axios.post(url_gastos, {option:4, embarque: this.embActual, 
                         gasto: this.idGasto, cantidad: this.cantidad, concepto: this.concepto, kilos: this.kilos_bolsas}).then(response =>{
                            //console.log(response.data);
                            if(response.data=="OK"){
                                this.listarGastosEmbarque(this.embActual);
                                this.buscarGastosEmbarque(this.embActual);
                                this.listaP(this.embActual);
                                this.listaB(this.embActual);
                                this.listaTotalP();
                                this.listaTotalB();
                                this.mostrarR();
                                Swal.fire({
                                   title: 'Gasto Registrado',
                                   text: "Los datos se han registrado exitosamente",
                                   icon: 'success',
                                   backdrop: false
                               });
                            }else{
                                Swal.fire({
                                    title: 'Ocurrio un error',
                                    text: "No se logro registrar el dato",
                                    icon: 'error',
                                    backdrop: false
                                });
                            }
                        });
                         this.idGasto=0;
                         this.cantidad=0;
                         this.concepto='';
                         this.kilos_bolsas=0;
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
        },
        async btnModificar(id, idg, nombre, cantidad){
            if(idg == 1 || idg == 2 || idg == 3 || idg == 4 || idg == 21 || idg == 23 || idg == 24 || idg == 29){
                Swal.fire({
                    title: 'Usted no puede eliminar el registro',
                    text: 'El registro es autocalculado y no se permite elminar ni modificarlo',
                    icon: 'warning',
                    backdrop: false
                })
            }else{
                var cantidad_new=0;
                const { value: formBosas } = await Swal.fire({
                    title: "Actualizar Gasto "+nombre,
                    html: '<div class="form-group row">'+
                    '<label for="cantidad" class="col-sm-4 col-form-label text-dark text-right">Cantidad</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="cantidad-gasto" value="'+cantidad+'">'+
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
                        cantidad_new = document.getElementById('cantidad-gasto').value
                        ];
                    }
                })
                if(cantidad_new!=cantidad && formBosas){
                    this.actualizarGasto(id, cantidad, cantidad_new);
                }
            }
        },
        actualizarGasto(id, cant, cant_new){
            axios.post(url_gastos, {option:11, id:id, cantidad:cant, 
                cantidad_new:cant_new, embarque: this.embActual}).then(response=>{
                    //console.log(response.data);

                    this.listarGastosEmbarque(this.embActual);
                    this.buscarGastosEmbarque(this.embActual);
                    this.listaP(this.embActual);
                    this.listaB(this.embActual);
                    this.listaTotalP();
                    this.listaTotalB();
                    this.mostrarR();

                    this.buscarGastosEmbarque(this.embActual);
                    this.listarGastosEmbarque(this.embActual);
            });
        },
        btnEliminarGasto(id, idg, cantidad, nombre){
            if(idg == 1 || idg == 2 || idg == 3 || idg == 4 || idg == 23 || idg == 24 || idg == 29){
                Swal.fire({
                    title: 'Usted no puede eliminar el registro',
                    text: 'El registro es autocalculado y no se permite elminar ni modificarlo',
                    icon: 'warning',
                    backdrop: false
                })
            }else{
                Swal.fire({
                    title: '¿Esta seguro de liminar el gasto?',
                    text: "Al eliminar el gasto se restara de los gastos totales del embarque "+this.embActual,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Si, Eliminar',
                    cancelButtonText: 'Cancelar',
                    backdrop: false,
                }).then((result) => {
                    if (result.value) {
                        axios.post(url_gastos, {option:13, id:id, cantidad:cantidad, 
                            embarque: this.embActual}).then(response=>{
                                //console.log(response.data);
                                if(response.data=="OK"){

                                    this.listarGastosEmbarque(this.embActual);
                                    this.buscarGastosEmbarque(this.embActual);
                                    this.listaP(this.embActual);
                                    this.listaB(this.embActual);
                                    this.listaTotalP();
                                    this.listaTotalB();
                                    this.mostrarR();

                                    this.buscarGastosEmbarque(this.embActual);
                                    this.listarGastosEmbarque(this.embActual);
                                    Swal.fire({
                                        title: '¡Eliminado!',
                                        text: 'Se ha modificado la cantidad de gastos del embarque',
                                        icon: 'success',
                                        backdrop: false
                                    })
                                }else{
                                    Swal.fire({
                                        title: 'Ocurrio un error',
                                        text: 'No se ha logrado realizar la petición',
                                        icon: 'error',
                                        backdrop: false
                                    })
                                }
                            });
                        }
                    })
            }
        },
    //Cuentas
    //Dolares
        listaTotal(){
            axios.post(url_cuenta,{option:3, id:this.embActual}). then(response =>{
                this.listaT= response.data;
            });
        },
        listaD(embarque){
            axios.post(url_cuenta,{option:1, embarque: embarque}). then(response =>{
                this.listaDolares = response.data;
                //console.log(this.listaDolares);
            });
        },
        btnRegistro(concepto, ingreso, egreso){
            if(concepto != '' && (ingreso != 0 || egreso !=0) || this.taza!=0){
                this.agregarDolar(this.embActual, concepto, ingreso, egreso, this.taza);
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    icon: 'warning',
                    text: 'No se puede registra el dato',
                    backdrop: false
                });
            }
        },
        agregarDolar (id, concepto, ingreso, egreso, taza){
            axios.post(url_cuenta,{option:2, id:id, concepto:concepto, ingreso:ingreso, egreso:egreso, taza: taza}). then(response =>{
                //console.log(response.data);
                this.listaD(this.embActual);
                this.listaP(this.embActual);
                this.listaTotal();
                this.listaTotalP();
                this.mostrarR();
            });
            this.concepto='', this.ingreso=0, this.egreso=0, this.taza=0;
        },
        async modDolar(id, id_cuentaD, concepto, ingreso, egreso, saldo, taza){
            const { value: actDolares } = await Swal.fire({
                title: "Actualizar Registro",
                html: '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Concepto</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="con" value="'+concepto+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Ingreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="in" value="'+ingreso+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Egreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="eg" value="'+egreso+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Taza Camb.</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="tz" value="'+taza+'">'+
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
                        this.concep = document.getElementById('con').value,
                        this.ing= document.getElementById('in').value,
                        this.egre = document.getElementById('eg').value,
                        this.tc = document.getElementById('tz').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#con").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#in").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#eg").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#tz").addEventListener("keyup", confirmOnEnter);
                }

            })
            if(actDolares && this.concep != '' && (this.ing !=0 || this.egre !=0 )){
                axios.post(url_cuenta, {option:12, dato:1, id:id, id_C:id_cuentaD, concepto: this.concep, ingre:this.ing, egre:this.egre, 
                ingAnt: ingreso, egrAnt: egreso, saldo: saldo, taza: this.tc, embarque: this.embActual}).then(response=>{
                    //console.log(response.data);
                    if(response.data=='OK'){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Actualizados',
                            text: 'Se han guardado los cambios',
                            backdrop: false
                        });
                        this.listaD(this.embActual);
                        this.listaP(this.embActual);
                        this.listaTotal();
                        this.listaTotalP();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar la modificación',
                            backdrop: false
                        });
                    }
                });
            }else if(!actDolares){

            }else if(this.concep == '' || (this.ing ==0 && this.egre ==0 )){
                Swal.fire({
                    title: 'Verifique los datos',
                    icon: 'warning',
                    text: 'No se logro actualizar el registro.',
                    backdrop: false
                });
            }
            this.concep ='';
            this.ing=0;
            this.egre =0;
            this.tc =0;
        },
        deleteDolar(idT, idC, ing, egr, taza, saldo){
            Swal.fire({
                icon: 'question',
                title: 'Esta seguro de eliminar los datos',
                text: 'Se eliminará permanentemente el registro',
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    axios.post(url_cuenta, {option:13, dato:1, id:idT, id_C: idC, ingAnt: ing, 
                    egrAnt: egr, saldo: saldo, taza: taza}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Eliminados',
                            text: 'Se han eliminado los datos',
                            backdrop: false
                        });
                        this.listaD(this.embActual);
                        this.listaP(this.embActual);
                        this.listaTotal();
                        this.listaTotalP();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar el dato',
                            backdrop: false
                        });
                    }
                });
                }
            });
        },
    //Pesos
        listaTotalP(id){
            axios.post(url_cuenta,{option:5, id:this.embActual}). then(response =>{
                this.listaTP= response.data;
            });
        },
        listaP(embarque){
            axios.post(url_cuenta,{option:4, embarque: embarque}). then(response =>{
                this.listaPesos = response.data;
            });
        },
        btnRegPesos(conceptoP, ingresoP, egresoP){
            if(conceptoP != '' && (ingresoP != 0 || egresoP !=0)){
                this.agregarPesos(this.embActual, conceptoP, ingresoP, egresoP);
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    icon: 'warning',
                    text: 'No se puede registra el dato',
                    backdrop: false
                });
            }
        },
        agregarPesos(id, concepto, ingreso, egreso){
            axios.post(url_cuenta,{option:6, id:id, concepto:concepto, ingreso:ingreso, egreso:egreso}). then(response =>{
                this.listaD(this.embActual);
                this.listaP(this.embActual);
                this.listaTotal();
                this.listaTotalP();
                this.mostrarR();
            });
            this.conceptoP='', this.ingresoP=0, this.egresoP=0;
        },
        async modPesos(id, id_cuenta, concepto, ingreso, egreso, saldo){
            const { value: actPesos } = await Swal.fire({
                title: "Actualizar Registro",
                html: '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Concepto</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="con" value="'+concepto+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Ingreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="in" value="'+ingreso+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Egreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="eg" value="'+egreso+'">'+
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
                        this.concep = document.getElementById('con').value,
                        this.ing= document.getElementById('in').value,
                        this.egre = document.getElementById('eg').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#con").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#in").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#eg").addEventListener("keyup", confirmOnEnter);
                }

            })
            if(actPesos && this.concep != '' && (this.ing !=0 || this.egre !=0 )){
                axios.post(url_cuenta, {option:12, dato:2, id:id, id_C:id_cuenta, concepto: this.concep, 
                    ingre:this.ing, egre:this.egre, ingAnt: ingreso, egrAnt: egreso, 
                    saldo: saldo, taza: 0, embarque: this.embActual}).then(response=>{
                    //console.log(response.data);
                    if(response.data=='OK'){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Actualizados',
                            text: 'Se han guardado los cambios',
                            backdrop: false
                        });
                        this.listaP(this.embActual);
                        this.listaTotalP();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar la modificación',
                            backdrop: false
                        });
                    }
                });
            }else if(!actPesos){

            }else if(this.concep == '' || (this.ing ==0 && this.egre ==0 )){
                Swal.fire({
                    title: 'Verifique los datos',
                    icon: 'warning',
                    text: 'No se logro actualizar el registro.',
                    backdrop: false
                });
            }
            this.concep ='';
            this.ing=0;
            this.egre =0;
            this.tc =0;
        },
        deletePesos(idT, idC, ing, egr, saldo){
            Swal.fire({
                icon: 'question',
                title: 'Esta seguro de eliminar los datos',
                text: 'Se eliminará permanentemente el registro',
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    axios.post(url_cuenta, {option:13, dato:2, id:idT, id_C: idC, ingAnt: ing, 
                    egrAnt: egr, saldo: saldo, taza: 0}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Eliminados',
                            text: 'Se han eliminado los datos',
                            backdrop: false
                        });
                        this.listaP(this.embActual);
                        this.listaTotalP();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar el dato',
                            backdrop: false
                        });
                    }
                });
                }
            });
        },
    //Bolsas
        listaTotalB(id){
            axios.post(url_cuenta,{option:8, id:this.embActual}). then(response =>{
                this.listaTB= response.data;
            });
        },
        listaB(embarque){
            axios.post(url_cuenta,{option:9, embarque: embarque}). then(response =>{
                this.listaBolsas = response.data;
            });
        },
        btnRegBolsas(conceptoB, ingresoB, egresoB){
            if(conceptoB != '' && (ingresoB != 0 || egresoB !=0)){
                this.agregarBolsas(this.embActual, conceptoB, ingresoB, egresoB);
            }else{
                Swal.fire({
                    title: 'Datos incompletos',
                    icon: 'warning',
                    text: 'No se puede registra el dato',
                    backdrop: false
                });
            }
            this.conceptoB='', this.ingresoB=0, this.egresoB=0;
        },
        agregarBolsas(id, concepto, ingreso, egreso){
            axios.post(url_cuenta,{option:7, id:id, concepto:concepto, ingreso:ingreso, egreso:egreso}). then(response =>{
                this.listaTotalB();
                this.listaB(this.embActual);
                this.mostrarR();
            });
        },
        async modBolsas(id, id_cuenta, concepto, ingreso, egreso, saldo){
            const { value: actBolsas } = await Swal.fire({
                title: "Actualizar Registro",
                html: '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Concepto</label>'+
                    '<div class="col-sm-7"><input type="text" class="form-control" id="con" value="'+concepto+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Ingreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="in" value="'+ingreso+'">'+
                    '</div></div>'+
                    '<div class="form-group row">'+
                    '<label class="col-sm-4 col-form-label text-dark text-right">Egreso</label>'+
                    '<div class="col-sm-7"><input type="number" class="form-control" id="eg" value="'+egreso+'">'+
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
                        this.concep = document.getElementById('con').value,
                        this.ing= document.getElementById('in').value,
                        this.egre = document.getElementById('eg').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#con").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#in").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#eg").addEventListener("keyup", confirmOnEnter);
                }

            })
            if(actBolsas && this.concep != '' && (this.ing !=0 || this.egre !=0 )){
                axios.post(url_cuenta, {option:12, dato:3, id:id, id_C:id_cuenta, concepto: this.concep, 
                    ingre:this.ing, egre:this.egre, ingAnt: ingreso, egrAnt: egreso, 
                    saldo: saldo, taza: 0, embarque: this.embActual}).then(response=>{
                    //console.log(response.data);
                    if(response.data=='OK'){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Actualizados',
                            text: 'Se han guardado los cambios',
                            backdrop: false
                        });
                        this.listaB(this.embActual);
                        this.listaTotalB();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro realizar la modificación',
                            backdrop: false
                        });
                    }
                });
            }else if(!actBolsas){

            }else if(this.concep == '' || (this.ing ==0 && this.egre ==0 )){
                Swal.fire({
                    title: 'Verifique los datos',
                    icon: 'warning',
                    text: 'No se logro actualizar el registro.',
                    backdrop: false
                });
            }
            this.concep ='';
            this.ing=0;
            this.egre =0;
            this.tc =0;
        },
        deleteBolsas(idT, idC, ing, egr, saldo){
            Swal.fire({
                icon: 'question',
                title: 'Esta seguro de eliminar los datos',
                text: 'Se eliminará permanentemente el registro',
                backdrop: false,
                showConfirmButton: true,
                showCancelButton: true,
                confirmButtonText: 'Eliminar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.value) {
                    axios.post(url_cuenta, {option:13, dato:3, id:idT, id_C: idC, ingAnt: ing, 
                    egrAnt: egr, saldo: saldo, taza: 0}).then(response =>{
                    //console.log(response.data);
                    if(response.data=="OK"){
                        Swal.fire({
                            icon: 'success',
                            title: 'Datos Eliminados',
                            text: 'Se han eliminado los datos',
                            backdrop: false
                        });
                        this.listaB(this.embActual);
                        this.listaTotalB();
                        this.mostrarR();
                    }else{
                        Swal.fire({
                            icon: 'error',
                            title: 'Ocurrio un error inesperado',
                            text: 'No se logro registrar el dato',
                            backdrop: false
                        });
                    }
                });
                }
            });
        },
    //Resumen
        mostrarR(){
            axios.post(url_cuenta,{option:11, id:this.embActual}). then(response =>{
                this.listaR= response.data;
            });
        }
    },
    created: function(){
        this.listarEmbarquesActivos();
    },
    computed:{
    }
});