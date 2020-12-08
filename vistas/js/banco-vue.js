const banco = new Vue({
    el: '#bancos',
    data: {
    //Listas de Embarques
    	listaEmbarques: [], /* Lista de Embarques sin finalizar */
        id: 0, /* Datos para crear un embarque */
        fecha: '', /*  Datos para crear un embarque */
        selected: 0, /* Embarque SELECCIONADO*/
        embActual: '', /* Embarque SELECCIONADO - VAR. AUX */
        datosEmbarque: [], /* Datos generales del embarque actual*/

    //Cuenta en dolares Registro
        concepto:'', 
        ingreso:0,
        egreso:0,
        taza: 0,

    //Registro cuenta en Pesos
        conceptoP: '',
        ingresoP:0,
        egresoP:0,
    //Registro cuenta en Bolsas
        conceptoB: '',
        ingresoB:0,
        egresoB:0,

        listaPesos:[],
        listaDolares:[],
        listaBolsas: [],
        listaT:[],
        listaTP:[],
        listaTB:[],
        listaR:[],

    //Actualizar
        concep:'',
        ing:0,
        egre:0,
        tc:0

    },
    methods: {
        btnCargarDatos (){
            if(this.selected != 0 && this.selected != 'Sin datos...'){
                this.embActual = this.selected;
                this.listaD(this.embActual);
                this.listaP(this.embActual);
                this.listaB(this.embActual);
                this.listaTotal();
                this.listaTotalP();
                this.listaTotalB();
                this.mostrarR();
            }else{
                Swal.fire({
                    icon: 'error',
                    title: 'Dato no valido',
                    text: 'Selecciones un Número de Embarque',
                    backdrop: false
                });
            }
        },
        /**Registro de los gastos a la tabla Dolares */
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
        btncerrarCuenta(){
            Swal.fire({
              title: 'Cerrar Cuenta',
              text: "¿Esta seguro que desea cerrar la cuenta del Embarque "+this.embActual+"?",
              icon: 'warning',
              showCancelButton: true,
              confirmButtonColor: '#3085d6',
              cancelButtonColor: '#d33',
              confirmButtonText: 'Aceptar',
              cancelButtonText: 'Cancelar',
              backdrop: false
            }).then((result) => {
              if (result.value) {
                   this.cerrarCuenta(this.embActual);
                }
            });
        },
        //procedimimetos
        listarEmbarquesActivos (){
            axios.post(url_embarque,{option:15}).then(response =>{
                this.listaEmbarques = response.data;
                //console.log(this.listaEmbarques);
            });
        },
        listaD(embarque){
            axios.post(url_cuenta,{option:1, embarque: embarque}). then(response =>{
                this.listaDolares = response.data;
                //console.log(this.listaDolares);
            });
        },
        listaP(embarque){
            axios.post(url_cuenta,{option:4, embarque: embarque}). then(response =>{
                this.listaPesos = response.data;
            });
        },
        listaB(embarque){
            axios.post(url_cuenta,{option:9, embarque: embarque}). then(response =>{
                this.listaBolsas = response.data;
            });
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
                    console.log(response.data);
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
                    console.log(response.data);
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
        listaTotal(id){
            axios.post(url_cuenta,{option:3, id:this.embActual}). then(response =>{
                this.listaT= response.data;
            });
        },
        listaTotalP(id){
            axios.post(url_cuenta,{option:5, id:this.embActual}). then(response =>{
                this.listaTP= response.data;
            });
        },
        listaTotalB(id){
            axios.post(url_cuenta,{option:8, id:this.embActual}). then(response =>{
                this.listaTB= response.data;
            });
        },
        cerrarCuenta(id){
            axios.post(url_cuenta,{option:10, id:id}). then(response =>{
                console.log(response.data);
                if(response.data=="OK"){
                    location.reload(true);
                }else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrio un error',
                        text: 'No se logro realizar la petición',
                        backdrop: false
                    });
                }
            });
        },
        mostrarR(){
            axios.post(url_cuenta,{option:11, id:this.embActual}). then(response =>{
                this.listaR= response.data;
            });
        }
    },
    created: function(){
        this.listarEmbarquesActivos();
        this.listaD();
    },
    computed:{

    }
});