let ventanaAAbrir;
let snd; 
$(document).ready(function(){

    snd = new Audio("../vistas/assets/tono.wav");

    //iniciarSocket();
    $('.btn-sideBar-SubMenu').on('click', function(e){
        e.preventDefault();
        var SubMenu=$(this).next('ul');
        var iconBtn=$(this).children('.zmdi-caret-down');
        if(SubMenu.hasClass('show-sideBar-SubMenu')){
            iconBtn.removeClass('zmdi-hc-rotate-180');
            SubMenu.removeClass('show-sideBar-SubMenu');
        }else{
            iconBtn.addClass('zmdi-hc-rotate-180');
            SubMenu.addClass('show-sideBar-SubMenu');
        }
    });
    $('.btn-menu-dashboard').on('click', function(e){
        e.preventDefault();
        var body=$('.dashboard-contentPage');
        var sidebar=$('.dashboard-sideBar');
        if(sidebar.css('pointer-events')=='none'){
            body.removeClass('no-paddin-left');
            sidebar.removeClass('hide-sidebar').addClass('show-sidebar');
        }else{
            body.addClass('no-paddin-left');
            sidebar.addClass('hide-sidebar').removeClass('show-sidebar');
        }
    });

    $(".FormularioAjax").bind("submit",function(){
        // Capturamnos el boton de envío
        var btnEnviar = $("#btnEnviar");
        $.ajax({
            type: $(this).attr("method"),
            url: $(this).attr("action"),
            data:$(this).serialize(),
            beforeSend: function(){
                /*
                * Esta función se ejecuta durante el envió de la petición al
                * servidor.
                * */
                // btnEnviar.text("Enviando"); Para button 
                btnEnviar.val("Enviando"); // Para input de tipo button
                btnEnviar.attr("disabled","disabled");
            },
            complete:function(data){
                /*
                * Se ejecuta al termino de la petición
                * */
                btnEnviar.val("Registrar+");
                btnEnviar.removeAttr("disabled");
            },
            success: function(data){
                /*
                * Se ejecuta cuando termina la petición y esta ha sido
                * correcta
                * */
                $(".respuesta").html(data);
            },
            error: function(data){
                /*
                * Se ejecuta si la peticón ha sido erronea
                * */
                console.log("Problemas al tratar de enviar el formulario");
            }
        });
        // Nos permite cancelar el envio del formulario
        return false;
    });
});

function mostrar(){
    var select=document.getElementById("select");
    value= select.value;

    if(value==1){
        document.getElementById('idEmbarque').style.display='block';
        document.getElementById('idRango').style.display='none';
    }else{
        document.getElementById('idRango').style.display='block'; 
        document.getElementById('idEmbarque').style.display='none';
    }
}

function mostrarP(){
    var select=document.getElementById("selectP");
    value=select.value;
    if(value==1){
        document.getElementById('uno').style.display='block';
        document.getElementById('dos').style.display='none';
        document.getElementById('tres').style.display='none';
        document.getElementById('cuatro').style.display='none';
        document.getElementById('cinco').style.display='none';
        document.getElementById('seis').style.display='none';
    }else if(value==2){
        document.getElementById('uno').style.display='none';
        document.getElementById('dos').style.display='block';
        document.getElementById('tres').style.display='none';
        document.getElementById('cuatro').style.display='none';
        document.getElementById('cinco').style.display='none';
        document.getElementById('seis').style.display='none';
    }else if(value==3){
        document.getElementById('uno').style.display='none';
        document.getElementById('dos').style.display='none';
        document.getElementById('tres').style.display='block';
        document.getElementById('cuatro').style.display='none';
        document.getElementById('cinco').style.display='none';
        document.getElementById('seis').style.display='none';
    }else if(value==4){
        document.getElementById('uno').style.display='none';
        document.getElementById('dos').style.display='none';
        document.getElementById('tres').style.display='none';
        document.getElementById('cuatro').style.display='block';
        document.getElementById('cinco').style.display='none';
        document.getElementById('seis').style.display='none';
    }else if(value==5){
        document.getElementById('uno').style.display='none';
        document.getElementById('dos').style.display='none';
        document.getElementById('tres').style.display='none';
        document.getElementById('cuatro').style.display='none';
        document.getElementById('cinco').style.display='block';
        document.getElementById('seis').style.display='none';
    }else if(value==6){
        document.getElementById('uno').style.display='none';
        document.getElementById('dos').style.display='none';
        document.getElementById('tres').style.display='none';
        document.getElementById('cuatro').style.display='none';
        document.getElementById('cinco').style.display='none';
        document.getElementById('seis').style.display='block';
    }
}
function mostrarT(){
    var select=document.getElementById("selectT");
    value= select.value;

    if(value==1){
        document.getElementById('t1').style.display='block';
        document.getElementById('t2').style.display='none';
        document.getElementById('t3').style.display='none';
        document.getElementById('t4').style.display='none';
        document.getElementById('t5').style.display='none';
    }else if(value==2){
        document.getElementById('t1').style.display='none';
        document.getElementById('t2').style.display='block';
        document.getElementById('t3').style.display='none';
        document.getElementById('t4').style.display='none';
        document.getElementById('t5').style.display='none';
    }else if(value==3){
        document.getElementById('t1').style.display='none';
        document.getElementById('t2').style.display='none';
        document.getElementById('t3').style.display='block';
        document.getElementById('t4').style.display='none';
        document.getElementById('t5').style.display='none';
    }else if(value==4){
        document.getElementById('t1').style.display='none';
        document.getElementById('t2').style.display='none';
        document.getElementById('t3').style.display='none';
        document.getElementById('t4').style.display='block';
        document.getElementById('t5').style.display='none';
    }else{
        document.getElementById('t1').style.display='none';
        document.getElementById('t2').style.display='none';
        document.getElementById('t3').style.display='none';
        document.getElementById('t4').style.display='none';
        document.getElementById('t5').style.display='block';
    }
}
function mostrarG(){
    var select=document.getElementById("selectG");
    value=select.value;

    if(value==1){
        document.getElementById('gasto').style.display='block';
        document.getElementById('rend').style.display='none';
    }else if(value==2){
        document.getElementById('gasto').style.display='none';
        document.getElementById('rend').style.display='block';
    }  
}
//Rendimiento productores
function ocFechaRen(){
    document.getElementById('rendimeinto1').style.display='block';
    document.getElementById('rendimeinto2').style.display='none';
  
    //Tablas
    document.getElementById('rend1').style.display='block';
    document.getElementById('rend2').style.display='none';
}
function ocFechaRen2(){
    document.getElementById('rendimeinto1').style.display='none';
    document.getElementById('rendimeinto2').style.display='block';

    //tablas
    document.getElementById('rend1').style.display='none';
    document.getElementById('rend2').style.display='block';
}
//Pago peladores
function ocultarPago1(){
    document.getElementById('pagoPel1').style.display='block';
    document.getElementById('pagoPel2').style.display='none';
    //Botón grafica
    document.getElementById('btn1pago').style.display='block';
    document.getElementById('btn2pago').style.display='none';
    //Tablas
    document.getElementById('pago1').style.display='block';
    document.getElementById('pago2').style.display='none';
}
function ocultarPago2(){
    document.getElementById('pagoPel1').style.display='none';
    document.getElementById('pagoPel2').style.display='block';
    //graficas
    document.getElementById('btn1pago').style.display='none';
    document.getElementById('btn2pago').style.display='block';
    //tablas
    document.getElementById('pago1').style.display='none';
    document.getElementById('pago2').style.display='block';
}

//Abono de productores
function ocFechaAbon(){
    document.getElementById('abono1').style.display='block';
    document.getElementById('abono2').style.display='none';
    //Botón grafica
    document.getElementById('btn1Abon').style.display='block';
    document.getElementById('btn2Abon').style.display='none';
    //Tablas
    document.getElementById('tAbon1').style.display='block';
    document.getElementById('tAbon2').style.display='none';
}
function ocFechaAbon2(){
    document.getElementById('abono1').style.display='none';
    document.getElementById('abono2').style.display='block';
    //graficas
    document.getElementById('btn1Abon').style.display='none';
    document.getElementById('btn2Abon').style.display='block';
    //tablas
    document.getElementById('tAbon1').style.display='none';
    document.getElementById('tAbon2').style.display='block';
}
//Trabajadores
function ocultarFech1(){
    document.getElementById('trabajador1').style.display='block';
    document.getElementById('trabajador2').style.display='none';
    //Botón grafica
    document.getElementById('btn1').style.display='block';
    document.getElementById('btn2').style.display='none';
    //Tablas
    document.getElementById('bolsasP1').style.display='block';
    document.getElementById('bolsasP2').style.display='none';
}
function ocultarEmb1(){
    document.getElementById('trabajador1').style.display='none';
    document.getElementById('trabajador2').style.display='block';
    document.getElementById('btn1').style.display='none';
    document.getElementById('btn2').style.display='block';
    //tablas
    document.getElementById('bolsasP1').style.display='none';
    document.getElementById('bolsasP2').style.display='block';
}

function ocultarFech2(){
    document.getElementById('trabajador11').style.display='block';
    document.getElementById('trabajador22').style.display='none';
    //Botón grafica
    document.getElementById('btn11').style.display='block';
    document.getElementById('btn22').style.display='none';
    //Tablas
    document.getElementById('bolsasB1').style.display='block';
    document.getElementById('bolsasB2').style.display='none';
}
function ocultarEmb2(){
    document.getElementById('trabajador11').style.display='none';
    document.getElementById('trabajador22').style.display='block';
    document.getElementById('btn11').style.display='none';
    document.getElementById('btn22').style.display='block';
    //tablas
    document.getElementById('bolsasB1').style.display='none';
    document.getElementById('bolsasB2').style.display='block';
}
(function($){
    $(window).on("load",function(){
        $(".dashboard-sideBar-ct").mCustomScrollbar({
            theme:"light-thin",
            scrollbarPosition: "inside",
            autoHideScrollbar: true,
            scrollButtons: {enable: true}
        });
        $(".dashboard-contentPage, .Notifications-body").mCustomScrollbar({
            theme:"dark-thin",
            scrollbarPosition: "inside",
            autoHideScrollbar: true,
            scrollButtons: {enable: true}
        });
    });
})(jQuery);

$(document).ready(function(){
    $("#filtro").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#tablass tr").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
});

/*function iniciarSocket(){
    //Cambiar la ruta del servidor
    ws = new WebSocket("ws://127.0.0.1:9000/");

    ws.onopen = function(){
        console.log("Conexion establecida...");
    }
    ws.onmessage = function (dato){
        if(dato == null || dato == ""){
            console.log('No se enviaron datos al tablero');
        }else{
            console.log(dato.data);
            $('#listadeDatos').html(dato.data);
        }
    }
    ws.onclose = function(){
        console.log("Conexion cerrada...");
        //alert("Conexion cerrada...");
    }
}*/

/* Cmara de Trabajadores */
        function preview_snapshot() {

            // freeze camera so user can preview current frame
            Webcam.freeze();
            
            // swap button sets
            document.getElementById('pre_take_buttons').style.display = 'none';
            document.getElementById('post_take_buttons').style.display = '';
        }
        
        function cancel_preview() {
            // cancel preview freeze and return to live camera view
            Webcam.unfreeze();
            
            // swap buttons back to first set
            document.getElementById('pre_take_buttons').style.display = '';
            document.getElementById('post_take_buttons').style.display = 'none';
        }


        var url_login="http://localhost/PLATANERATAB/ajax/loginAjax.php";
        var url_productor="http://localhost/PLATANERATAB/ajax/productorAjax.php";
        var url_trabajador="http://localhost/PLATANERATAB/ajax/trabajadoresAjax.php";
        var url_embarque="http://localhost/PLATANERATAB/ajax/embarqueAjax.php";
        var url_pdf="http://localhost/PLATANERATAB/ajax/pdfAjax.php";
        var url_cuenta="http://localhost/PLATANERATAB/ajax/bancoAjax.php";
        var url_gastos="http://localhost/PLATANERATAB/ajax/gastosAjax.php";
        var url_consultas="http://localhost/PLATANERATAB/ajax/consultasAjax.php";
        url_update= "http://localhost/PLATANERATAB/ajax/updateAjax.php";