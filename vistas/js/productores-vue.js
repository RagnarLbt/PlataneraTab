
const productor= new Vue({
    el: '#productores',
    data: {
        totalRegistros: 0,
        lista:[],
        id: "",
        nombre:"",
        apPat:"",
        apMat:"",
        edad: 0,
        direccion: "",
        telefono: "",
        cuenta: "",
        total:0,
        foto:'',
        aux:'',
        nombreaux: ''
    },
    methods:{
        //Botones
        camera(){
            Webcam.set({
                width: 320,
                height: 240,
                image_format: 'jpeg',
                jpeg_quality: 90
            });
            Webcam.attach( '#my_camera' );
        },
        save_photo() {
            var _self=this;
            // actually snap photo (from preview freeze) and display it
            Webcam.snap( function(data_uri) {
                _self.foto=data_uri;
                // display results in page
                document.getElementById('results').innerHTML = 
                '<img src="'+data_uri+'" style="max-width:100%;width:auto;height:auto;" id="img" /><br/></br>';
                
                // shut down camera, stop capturing
                //Webcam.reset();
                
                // show results, hide photo booth
                document.getElementById('results').style.display = '';
                //document.getElementById('my_photo_booth').style.display = 'none';
            });
        },
        //Boton Registrar
        btnRegistro (){
            if(this.nombre == "" || this.apPat == "" || this.apMat == "" || this.direccion ==""){
                console.log(this.nombre+" "+this.apPat+" "+this.apMat+" "+this.edad+" "+this.direccion);
                Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'Datos no registrados',
                    backdrop: false
                });
            }else{
            	Swal.fire({
                    title: 'Registrar Trabajador',
            		text: 'Esta seguro que desea registrar a '+this.nombre,
                    icon: 'question',
            		focusConfirm: false,
            		showCancelButton: true,
            		cancelButtonText: 'Cancelar',
            		confirmButtonText: 'Registrar',
            		confirmButtonColor:'#40B340',
            		cancelButtonColor:'#FF0000',
                    backdrop: false,
                }).then((result) => {
                    if (result.value) {
                        this.registrarProductor();
                    }
                });
            }
        },
        //Boton Actualizar
        async btnVer(id, nombre, app, apm, edad, tel, dir, cuenta, foto){
            await Swal.fire({
                title: 'Datos del productor: '+id,
                html: '<input type="hidden" value="'+id+'" id="id" />'+
                '<div class="row col-sm-12 container">'+
                '<div class="col-sm-5">'+
                '<div class="form-group p-1 mt-3"><img src="'+foto+'" width="100%" alt="foto"></div>'+
                '</div>'+
                '<div class="col-sm-7 p-3">'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Nombre</label><div class="col-sm-5"><input disabled type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreTrabajador" value="'+nombre+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Paterno</label><div class="col-sm-5"><input disabled type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoPaterno" value="'+app+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Apellido Materno</label><div class="col-sm-5"><input disabled type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidoMaterno" value="'+apm+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Edad</label><div class="col-sm-5"><input disabled type="text" class="form-control" id="edad" name="edad-reg-trabajador" value="'+edad+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Telefono</label><div class="col-sm-5"><input disabled type="text" class="form-control" maxlength="10" id="tel" value="'+tel+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">Dirección</label><div class="col-sm-5"><input disabled type="text" class="form-control" id="dir" value="'+dir+'"></div></div>'+
                '<div class="form-group row"><label class="col-sm-5 col-form-label text-dark text-right">No. Cuenta</label><div class="col-sm-5"><input disabled type="text" class="form-control" maxlength="16" id="cuenta" value="'+cuenta+'"></div></div>'+
                '</div></div>',
                focusConfirm: false,
                width: 900,
                showCloseButton: true,
                focusConfirm: true,
                confirmButtonText: 'Aceptar',
                cancelButtonColor:'#FF0000',
                backdrop: false
            })
            
        },   
        btnUpdate (id, nombre, app, apm, edad, tel, dir, cuenta, foto){
            this.id = id;
            this.nombre = nombre;
            this.apPat = app;
            this.apMat = apm;
            this.edad = edad;
            this.telefono = tel;
            this.direccion = dir;
            this.cuenta = cuenta;
            this.foto=foto;
            this.aux=foto;
            this.nombreaux=nombre+' '+app;

            this.camera();
            results.style.dsiplay = 'block';
            salvar.style.display = 'none';
            modifi.style.display = 'block';
            registroBtn.style.display = 'none';
            results.innerHTML ='<img src="'+this.foto+'" style="max-width:100%;width:auto;height:auto;" id="img" /><br/></br>';;
            //registroBtn.style.display = 'none';
            tablas_trab.style.display="none";
            registro.style.display="block";
        },

        //PROCEDIMIENTOS
        //Listar Datos
        listarDatos (){
            axios.post(url_productor,{option:4}). then(response =>{
                this.lista = response.data;
                //console.log(this.lista);
            });
        },
        //Procedimiento CREAR.       
        registrarProductor(){
        	axios.post(url_productor,{option:1, foto:this.foto, nombre: this.nombre, app: this.apPat, apm: this.apMat,
             edad: this.edad, tel: this.telefono, dir: this.direccion, cuenta: this.cuenta}). then(response =>{
                 console.log(response.data);
                if(response.data=="OK"){
                    const Toast = Swal.mixin({
                        toast: true,
                        position: 'top',
                        showConfirmButton: false,
                        timer: 1200
                    });
                    Toast.fire({
                        icon: 'success',
                        title: 'Trabajador Registrado!',
                        background: '#FFFFFF',
                        backdrop: false
                    });
                    this.nombre = "", this.apPat = "", this.apMat = "", this.edad = 0, this.direccion ="";
                    this.foto = "", this.telefono = "", this.cuenta = "";
                    this.listarDatos();
                    results.style.display = 'none';
                }else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrio un error',
                        text: 'No se logro registrar los datos',
                        backdrop: false
                    });
                }
        	});
        	this.foto="", this.nombre="", this.apPat="", this.apMat="", this.edad=0, this.telefono="", this.direccion="", this.cuenta="";
        },
        formularioRegistro (){
            this.foto="";
            registroBtn.style.display = 'none';
            document.getElementById('results').innerHTML = "";
            this.camera();
            //registroBtn.style.display = 'none';
            tablas_trab.style.display="none";
            registro.style.display="block";
        },
        btnCancelarRegistro(){
            this.id='',this.nombre='',this.apPat='',this.apMat='',this.edad=0, this.telefono='', this.direccion='', this.cuenta='', this.foto='';
            this.foto=null;
            modifi.style.display = 'none';
            salvar.style.display = 'block';
            registroBtn.style.display = 'block';
            tablas_trab.style.display="block";
            registro.style.display="none";
            pre_take_buttons.style.display = 'block';
            my_camera.style.display = 'block';
            Webcam.reset();
        },
        //Editar Datos de Productor
        actualizarDatos(id, nombre, apPat, apMat, edad, telefono, direccion, cuenta,  foto){
             axios.post(url_productor,{option:2,  nombreaux: this.nombreaux, aux:this.aux, foto:foto, id: id, nombre: nombre, app: apPat, apm: apMat,
                edad: edad, tel: telefono, dir: direccion, cuenta: cuenta}). then(response =>{
                    console.log(response.data);
                    if(response.data=="OK"){
                            Swal.fire({
                               title: '¡Actualizado!',
                               text: 'El registro ha sido actualizado.',
                               icon: 'success',
                               backdrop: false
                           })
                         
                           this.btnCancelarRegistro();
                           this.listarDatos();
                           this.id='',this.nombre='',this.apPat='',this.apMat='',this.edad=0, this.telefono='', this.direccion='', this.cuenta='';
                       }else{
                        this.btnCancelarRegistro();
                        this.listarDatos();
                        this.id='',this.nombre='',this.apPat='',this.apMat='',this.edad=0, this.telefono='', this.direccion='', this.cuenta='';
                            Swal.fire({
                               title: 'Ocurrio un error',
                               text: 'No se logro actualizar el registro',
                               icon: 'error',
                               backdrop: false
                           })
                       }
                   });
        },
        /*Eliminar Datos de Productor
        eliminarProductor: function(id){
            axios.post(url_productor, { option:3, id:id }).then(response =>{           
                this.listarDatos();
            });
        }

        */
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