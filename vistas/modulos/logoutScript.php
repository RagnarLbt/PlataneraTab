 <script>    
    $('.btn-exit-system').on('click', function(e){
        e.preventDefault();
        var token=$(this).attr('href');
        Swal.fire({
            title: '¿Esta seguro que desea salir?',
            text: "Su sesión se cerrara temporalmete",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#0DC143',
            cancelButtonColor: '#F44336',
            confirmButtonText: '<i class="fa fa-thumbs-up"></i> Si, Salír!',
            cancelButtonText: '<i class="fas fa-times-circle"></i> No, Cancelar!',
            backdrop: false
        }).then((result) => {
            if (result.value) {
                $.ajax({
                    url:'<?php echo SERVERURL; ?>ajax/loginAjax.php?token='+token,
                    success: function(data){
                        if(data=="true"){
                            window.location.href="<?php echo SERVERURL; ?>";
                        }else{ if(data=="false"){
                            Swal.fire(
                                "Ocurrio un error",
                                "No se logro cerrara la sesión "+data,
                                "error"
                                );
                        }}
                    }
                });
            }
        });
    });
</script>