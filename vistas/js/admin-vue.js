var url_admin="http://localhost/PLATANERATAB/ajax/administradorAjax.php";
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
        tipo: 0,
        listaCapturista: ''
    },
    methods:{
        async btnRegistro (){
            const{ value:formRegistro} = await Swal.fire({
                title: 'Registrar Usuario',
                html: '<div class="form-group row">'+
                '<label for="nombre" class="col-sm-4 col-form-label text-dark text-right">Nombre</label>'+
                '<div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreAdmin" name="nombre-reg-admin"></div></div>'+
                '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Apellidos</label>'+
                '<div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="apellidosAdmin" name="ap-reg-admin"></div></div>'+
                '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Genero</label>'+
                '<div class="col-sm-7"><select class="form-control" name="tipo-reg-genero" required id="optionsGenero">'+
                '<option selected value="Masculino">Masculino</option><option value="Femenino">Femenino</option></select></div></div>'+
                '<div class="form-group row"><label for="userAdmin" class="col-sm-4 col-form-label text-dark text-right">User Name</label>'+
                '<div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="userAdmin" name="user-reg-admin"></div></div>'+
                '<div class="form-group row"><label for="pass1" class="col-sm-4 col-form-label text-dark text-right">Constraseña</label>'+
                '<div class="col-sm-7"><input type="password" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="pass1" name="pass1-reg-admin"></div></div>'+
                '<div class="form-group row"><label for="pass2" class="col-sm-4 col-form-label text-dark text-right">Contraseña*</label><div class="col-sm-7">'+
                '<input type="password" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="pass2" name="pass2-reg-admin" placeholder="Escriba su contraseña nuevamente"></div></div>'+
                '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Privilegios</label><div class="col-sm-7">'+
                '<select class="form-control" name="tipo-reg-admin" required id="optionsPrivilegio"><option selected value="1">Administrador</option><option value="2">Captura</option>'+
                '</select></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                cancelButtonText: 'Cancelar',
                confirmButtonText: 'Registrar',
                confirmButtonColor:'#40B340',          
                cancelButtonColor:'#FF0000',
                backdrop: false,
                preConfirm: () => {            
                    return [
                        this.nombre = document.getElementById('NombreAdmin').value+" "+document.getElementById('apellidosAdmin').value,
                        //this.apellidos = document.getElementById('apellidosAdmin').value,
                        //this.genero= document.querySelector('input[name = "optionsGenero"]:checked').value,
                        this.genero= document.getElementById('optionsGenero').value,
                        //this.genero = document.getElementsByName('optionsGenero').value,   
                        this.user = document.getElementById('userAdmin').value,
                        this.pass1 = document.getElementById('pass1').value,
                        this.pass2 = document.getElementById('pass2').value,
                        //this.tipo = document.querySelector('input[name = "optionsPrivilegio"]:checked').value
                        this.tipo = document.getElementById('optionsPrivilegio').value
                    ]
                }
            });
            if(this.nombre == "" || this.genero == "" || this.user == "" || 
                this.pass1 == "" || this.pass2 == ""|| this.tipo == ""){
                    Swal.fire({
                        icon: 'warning',
                        title: 'Datos incompletos',
                        text: 'Datos no registrados',
                        backdrop: false
                    });
            }else {
                if (this.pass1 != this.pass2){
                    Swal.fire({
                        icon: 'warning',
                        title: 'Contraseñas incorrectas',
                        text: 'Las contraseñas no coinciden, datos no registrados',
                        backdrop: false
                    });
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
                        icon: 'success',
                        title: '¡Usuario Registrado!',
                        background: '#FFFFFF',
                        backdrop: false
                    })

                }
            }
        },
        btnDelete (id){
            Swal.fire({
                title: 'Se eliminara permanentemente al usuario '+id,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                confirmButtonText: 'Eliminar',
                backdrop: false
            }).then((result) => {
                if (result.value) {
                    this.deleteUsuario(id);
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
        async btnUpdate (id, nombre, genero, user, tipo, session){
            var gm=null, gf=null, ta=null, tc=null, act=null;
            if(genero=='Masculino'){
                gm='selected';
            }else{
                gf='selected';
            }
            if(tipo == 2){
                tc='selected';
            }else{
                ta='selected';
            }

            if(session==1){
                act='';
            }else{
                act='disabled';
            }
            await Swal.fire({
                title: 'Actualizar Datos',
                html: '<div class="form-group row"><input type="hidden" value="'+id+'" id="idU">'+
                '<label for="nombre" class="col-sm-4 col-form-label text-dark text-right">Nombre</label>'+
                '<div class="col-sm-7"><input type="text" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="NombreU" value="'+nombre+'" name="nombre-reg-admin"></div></div>'+
                '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Genero</label>'+
                '<div class="col-sm-7"><select class="form-control" name="tipo-reg-genero" required id="optionsG">'+
                '<option '+gm+' value="Masculino">Masculino</option><option '+gf+' value="Femenino">Femenino</option></select></div></div>'+
                '<div class="form-group row"><label for="userA" class="col-sm-4 col-form-label text-dark text-right">User Name</label><div class="col-sm-7">'+
                '<input type="text" value="'+user+'" placeholder="Escriba un nombre de usuario" class="form-control" pattern="-?[A-Za-z0-9áéíóúÁÉÍÓÚ ]*(\.[0-9]+)?" id="userA" name="user-reg-admin"></div>'+
                '</div>'+
                '<div class="form-group row"><label class="col-sm-4 col-form-label text-dark text-right">Privilegios</label><div class="col-sm-7">'+
                '<select '+act+' class="form-control" name="tipo-reg-admin" required id="optionsP"><option '+ta+' value="1">Administrador</option><option '+tc+' value="2">Captura</option>'+
                '</select></div></div>',
                focusConfirm: false,
                showCancelButton: true,
                backdrop: false
            }).then((result) => {
                if(result.value){
                    this.id=document.getElementById('idU').value,
                    this.nombre = document.getElementById('NombreU').value,
                    this.genero = document.getElementById('optionsG').value,
                    this.user = document.getElementById('userA').value,
                    this.tipo = document.getElementById('optionsP').value

                    this.editarUsuario(this.id, this.user, this.nombre, this.genero, this.tipo);
                    Swal.fire({
                        title: '¡Actualizado!',
                        text: 'El registro ha sido actualizado.',
                        icon: 'success',
                        backdrop: false
                    });
                }
            });
        },
        async btnContras(id){
            var p1=null, p2=null;
            const{ value:formRestPass} = await Swal.fire({
                title: 'Restaurar Contraseña',
                html: '<div class="form-group row mt-4">'+
                '<label for="pass1" class="col-sm-5 col-form-label text-dark text-right">Nueva Constraseña</label>'+
                '<div class="col-sm-6">'+
                '<input type="password" class="form-control" id="pass1" name="pass1-reg-admin"></div></div>'+
                '<div class="form-group row">'+
                '<label for="pass2" class="col-sm-5 col-form-label text-dark text-right">Confirmar*</label>'+
                '<div class="col-sm-6">'+
                '<input type="password" class="form-control" id="pass2" name="pass2-reg-admin" placeholder="Confirmar contraseña"></div></div>',
                backdrop: false,
                confirmButtonText: 'Aceptar',
                cancelButtonText: 'Cancelar',
                confirmButtonColor:'#d33',
                cancelButtonColor:'#3085d6',
                focusConfirm: false,
                showCancelButton: true,
                closeButton: true,
                preConfirm: () => {        
                    return [
                        p2 = document.getElementById('pass2').value,
                        p1 = document.getElementById('pass1').value
                    ];
                },
                onOpen: (modal) => {
                    confirmOnEnter = (event) => {
                        if (event.keyCode === 13) {
                            event.preventDefault();
                            modal.querySelector(".swal2-confirm").click();
                        }
                    };
                    modal.querySelector("#pass2").addEventListener("keyup", confirmOnEnter);
                    modal.querySelector("#pass1").addEventListener("keyup", confirmOnEnter);
                }
            })
            if(p1 == '' || p2 == '' || p1 == null || p2 == null){
                Swal.fire({
                    icon: 'warning',
                    title: 'Datos incompletos',
                    text: 'No se realizo ningun cambio',
                    backdrop: false
                })
            }else if(p1!=p2){
                Swal.fire({
                    icon: 'error',
                    title: 'Contraseña incorecta',
                    text: 'Asegurese de colocar correctamente las contraseñas',
                    backdrop: false
                })
            }else{
                this.editarContrasenna(id, p1, p2);
            }
        },
        //Procedimientos
        listaUsuarios: function(){
            axios.post(url_admin,{option:3}). then(response =>{
                this.lista = response.data;
                //console.log(this.lista);
            });
        },
        listaCap(){
            axios.post(url_admin,{option:5}). then(response =>{
                this.listaCapturista = response.data;
            });
        },
        altaUsuario (){
            axios.post(url_admin, {option:1, nombre:this.nombre, genero:this.genero, 
                user:this.user, clave:this.clave, tipo:this.tipo }).then(response =>{
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
        deleteUsuario(id){
            axios.post(url_admin, { option:2, id:id }).then(response =>{           
                this.listaUsuarios();
            });
        },
        editarUsuario: function(id, user, nombre, genero, tipo){
            axios.post(url_admin, {option:4, id:id, user:user, nombre:nombre, genero:genero, tipo:tipo }).then(response =>{
                this.listaUsuarios();
                this.listaCap();
            });
        },
        editarContrasenna(id, p1, p2){
            axios.post(url_admin, {option:6, id:id, p1:p1, p2:p2 }).then(response =>{
                this.listaUsuarios();
                this.listaCap();
                //console.log(response.data);
                if(response.data=="Ok"){
                    Swal.fire({
                        icon: 'success',
                        title: 'Contraseña Restaurada',
                        text: 'Para confirmar el cambio cierre sesión y vuelva a iniciarla',
                        backdrop: false
                    })
                }else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Error inesperado',
                        text: 'Se produjo un error al conectarse con el servidor',
                        backdrop: false
                    })
                }
            });
        }
    },
    created: function(){
        this.listaUsuarios();
        this.listaCap();
    }
});