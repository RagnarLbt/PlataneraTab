const gasto = new Vue({
	el: '#gastos',
	data: {
	//Datos generales
		listaEmbarques: [], /* Lista de Embarques sin finalizar */
		selected: 0, /* Embarque SELECCIONADO*/
		embActual: '', /* Embarque SELECCIONADO - VAR. AUX */
		datosGastos: [], /* Datos generales del embarque actual */

	//Lista de gastos
		idGasto: 0,
		listGastos:[], /* Listas de los gastos de la BD */
		listaGastosTipo: [],
	
	//Variables de registro
		cantidad: 0,
		concepto: '',
        kilos_bolsas:0

	},
	methods:{
		//Cargar datos generales de gastos
            //Listar Embarques
            listarEmbarquesActivos (){
            	axios.post(url_gastos,{option:1}).then(response =>{
            		this.listaEmbarques = response.data;
                    //console.log(this.listaEmbarques);
                });
            },
            //Obtener lista de gastos que se han realizado en el embarque seleccionado
            listarGastosEmbarque(id){
            	axios.post(url_gastos,{option:5, id:id, con: 1}).then(response =>{
                    this.listaGastosTipo = response.data;
                });
            },
            /* Boton para obtener todos los gastos del embarque seleccionado */
            btnCargarDatos (){
                if(this.selected != 0 && this.selected != 'Sin datos...'){
                    this.embActual = this.selected;
                    this.buscarGastosEmbarque(this.embActual);
                    this.listaTipoGastos();
                    this.listarGastosEmbarque(this.embActual);
                }else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Dato no valido',
                        text: 'Selecciones un Número de Embarque',
                        backdrop: false
                    });
                }
            },
            buscarGastosEmbarque(embarque){
                axios.post(url_gastos,{option:2, id:embarque}).then(response =>{
                    this.datosGastos = response.data;
                });
            },

        //Listar tipos de gastos
        	listaTipoGastos(){
        		axios.post(url_gastos,{option:3}).then(response =>{
                    this.listGastos = response.data;
                });
        	},

        //Botones
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
                            console.log(response.data);
                            if(response.data=="OK"){
                                this.listarGastosEmbarque(this.embActual);
                                this.buscarGastosEmbarque(this.embActual);
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
                    console.log(response.data);
                    this.buscarGastosEmbarque(this.embActual);
                    this.listarGastosEmbarque(this.embActual);
                });
            },
            btnEliminarGasto(id, idg, cantidad, nombre){
                if(idg == 1 || idg == 2 || idg == 3 || idg == 4 || idg == 21 || idg == 23 || idg == 24 || idg == 29){
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
                                    console.log(response.data);
                                    if(response.data=="OK"){
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
            }
	},
	created: function(){ 
        this.listarEmbarquesActivos();
    },
	computed:{

	}
});