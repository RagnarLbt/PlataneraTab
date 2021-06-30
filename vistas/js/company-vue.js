const empresa = new Vue({
	el:"#empresa",
	data:{
	//Precios y Costo
		id:0,
		precio: '',
		pago_pel: '',
		pago_bol: '',
		pre: 0,
		p_pel: 0,
		p_bol: 0,
	//Gastos
		gastoNuevo:null,
		getPagos:[],
		listGastos: []
	},
	methods: {
	//Precios
		obtenerPrecio(){
			axios.post(url_gastos,{option:6}).then(response =>{
				this.getPagos = response.data;
			});
		},
		obtenerGastos(){
			axios.post(url_gastos,{option:12}).then(response =>{
				this.listGastos = response.data;
			});
		},
		cantidadesCostos(){
            this.precio='';
            this.pago_pel='';
            this.pago_bol='';
            for(dat of this.getPagos){
                this.precio=dat.cantidad;
                this.pago_pel=dat.pago_pelador;
                this.pago_bol=dat.pago_bolsero;
            }
        },
		async btnModificar(id){
			this.cantidadesCostos();
			const { value: formPrecio } = await Swal.fire({
				title: 'Modificar Precios y Costo',
				html: '<div class="row">'+
				'<div class="col-sm-12">'+
				'<div class="form-group row">'+
				'<label class="col-sm-4 col-form-label text-right">Precio de Compra</label>'+
				'<div class="col-sm-8">'+
				'<input type="number" step="0.1" class="form-control" value="'+this.precio+'" id="compra">'+
				'</div>'+
				'</div>'+
				'<input type="hidden" value="'+id+'" id="id_p"/>'+
				'<div class="form-group row">'+
				'<label class="col-sm-4 col-form-label text-right">Pago a Peladores</label>'+
				'<div class="col-sm-8">'+
				'<input type="number" step="0.1" class="form-control" value="'+this.pago_pel+'" id="p_pelador">'+
				'</div>'+
				'</div>'+
				'<div class="form-group row">'+
				'<label class="col-sm-4 col-form-label text-right">Pago a Bolseros</label>'+
				'<div class="col-sm-8">'+
				'<input type="number" step="0.1" class="form-control" value="'+this.pago_bol+'" id="p_bolsero">'+
				'</div>'+
				'</div>'+
				'</div>'+
				'</div>',
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Aceptar',
				cancelButtonText: 'Cancelar',
				backdrop: false,
				preConfirm: () => {
                    return [
                    	this.id=document.getElementById("id_p").value,
                        this.pre = document.getElementById('compra').value,
                        this.p_pel = document.getElementById('p_pelador').value,
                        this.p_bol = document.getElementById('p_bolsero').value
                    ];
                }
            })
            if(this.pre == 0 || this.p_pel == 0 || this.p_bol == 0){
            	Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'No se logro registra el cambio',
                    backdrop: false
                })
            }else{
            	this.modificarPrecios();
            	Swal.fire({
                    icon: 'success',
                    title: 'Datos modificados',
                    text: 'Se han registrado el cambio de precio y costos',
                    backdrop: false
                })
            }
		},
        modificarPrecios(){
        	axios.post(url_gastos, {option:7, id:this.id, cantidad: this.pre, pelador:this.p_pel, 
        		bolsero: this.p_bol}).then(response =>{
                this.obtenerPrecio();
            });
        },
	//Gastos
		btnRegistroGasto(){
			if(this.gastoNuevo != null && this.gastoNuevo != ''){
				axios.post(url_gastos, {option:8, gasto: this.gastoNuevo}).then(response =>{
	                this.obtenerGastos();
	            });
			}else{
				Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'No se logro registra el tipo de gasto',
                    backdrop: false
                });
			}
            this.gastoNuevo='';
		},
		/*btnDelete(id){
			Swal.fire({
				title: '¿Está seguro de borrar el registro: '+id+"?",         
				icon: 'warning',
				showCancelButton: true,
				confirmButtonColor:'#d33',
				cancelButtonColor:'#3085d6',
				confirmButtonText: 'Borrar',
				backdrop: false
			}).then((result) => {
				if (result.value) {
					this.eliminarGasto(id);
                    //y mostramos un mensaje sobre la eliminación
                    Swal.fire({
                    	title: '¡Eliminado!',
                    	text: 'El registro ha sido borrado.',
                    	icon: 'success',
                    	backdrop: false
                    	})
                }
            })
		},
		eliminarGasto(id){
			axios.post(url_gastos, {option:9, id_gasto:id}).then(response =>{
                this.obtenerGastos();
            });
		},*/
		async btnUpdate(id, nombre){
			await Swal.fire({
        		title: 'Actualizar Datos',
        		html: '<input type="hidden" value="'+id+'" id="id_g" />'+
        		'<div class="form-group row mt-4">'+
        		'<label class="col-sm-5 col-form-label text-dark text-right">Nombre</label>'+
        		'<div class="col-sm-5">'+
        		'<input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="nombreGasto" value="'+nombre+'">'+
        		'</div></div>',
        		focusConfirm: false,
        		showCancelButton: true,
        		cancelButtonText: 'Cancelar',
        		confirmButtonText: 'Actualizar',
        		cancelButtonColor:'#FF0000',
        		backdrop: false
        	}).then((result) => {
        		if(result.value){
        			id = document.getElementById('id_g').value,
        			nombre = document.getElementById('nombreGasto').value

        			this.modificarGasto(id,nombre);
        			Swal.fire({
        				title: '¡Actualizado!',
        				text: 'El registro ha sido actualizado.',
        				icon: 'success',
        				backdrop: false
        				})
        		}
        	});			
		},
		modificarGasto(id, nombre){
			axios.post(url_gastos, {option:10, id:id, nombre:nombre}).then(response =>{
                this.obtenerGastos();
            });
		}
	},
	created: function(){
		this.obtenerGastos(),
		this.obtenerPrecio()
	},
	computed:{}
});