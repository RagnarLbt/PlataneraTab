<?php
	if ($peticionAjax) {
		require_once "../modelos/administradorModelo.php";
	} else {
		require_once "./modelos/administradorModelo.php";
    }

    class administradorControlador extends administradorModelo{
        
        public function agregar_admin_controlador(){
            $user= mainModel::limpiar_Cadena(strtoupper($_POST['user']));
            $pass1= mainModel::limpiar_Cadena(strtoupper($_POST['clave']));
            $nombre= mainModel::limpiar_Cadena(strtoupper($_POST['nombre']));
            $ap= mainModel::limpiar_Cadena(strtoupper($_POST['apellidos']));
            $genero= mainModel::limpiar_Cadena($_POST['genero']);
            $tipo= mainModel::limpiar_Cadena($_POST['tipo']);
           
                $datos=[
                    "User"=>$user,
                    "Password"=>$pass1,
                    "Nombre"=>$nombre,
                    "Apellidos"=>$ap,
                    "Genero"=> $genero,
                    "Tipo"=>$tipo
                ];

                $sql=administradorModelo::agregar_admin_modelo($datos);
                return $sql;
        }

        public function eliminar_admin_controlador(){
			$id = mainModel::limpiar_cadena($_POST['id']);
			$sql=administradorModelo::eliminar_admin_modelo($id);
			return $sql;
		}

		public function lista_admin_controlador(){
			$sql=administradorModelo::lista_admin_modelo();
			return $sql;
		}

		public function buscar_admin_controlador(){
			$sql=administradorModelo::buscar_admin_modelo();
			return $sql;
		}
    }