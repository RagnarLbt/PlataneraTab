<?php
	if ($peticionAjax) {
		require_once "../modelos/administradorModelo.php";
	} else {
		require_once "./modelos/administradorModelo.php";
    }

    class administradorControlador extends administradorModelo{
        
        public function agregar_admin_controlador(){
            $nombre= strtolower($_POST['nombre']);
            $genero= $_POST['genero'];
            $user= strtolower($_POST['user']);
            $pass1= strtolower($_POST['clave']);
            $tipo= strtolower($_POST['tipo']);

            $datos=[
                "User"=>$user,
                "Password"=>mainModel::encryptar($pass1),
                "Nombre"=>$nombre,
                "Genero"=> $genero,
                "Tipo"=>$tipo
            ];

            $sql=administradorModelo::agregar_admin_modelo($datos);
            return $sql;
        }

        public function eliminarAdminControlador(){
			$id = $_POST['id'];
			
			$sql=administradorModelo::eliminar_admin_modelo($id);
			return $sql;
		}

		public function lista_admin_controlador(){
			$sql=administradorModelo::lista_admin_modelo();
			return $sql;
		}

		public function editar_admin_controlador(){
            
            $id=$_POST['id'];
            $user= strtolower($_POST['user']);
            $nombre= strtolower($_POST['nombre']);
            $genero= $_POST['genero'];
            $tipo= $_POST['tipo'];

            $datos=[
                "Id"=>$id,
                "User"=>$user,
                "Nombre"=>$nombre,
                "Genero"=>$genero,
                "Tipo"=>$tipo,
            ];

            $sql=administradorModelo::editar_admin_modelo($datos);
            return $sql;
		}

        public function editar_capturista_controlador(){
            $sql=administradorModelo::lista_capturista_modelo();
            return $sql;
        }

        public function editar_pass_controlador(){
            $id=$_POST['id'];
            $pas1=mainModel::encryptar($_POST['p1']);

            $sql=mainModel::ejecutar_consulta_simple("UPDATE `usuario` SET `password`='$pas1' WHERE `id`=$id");

            if($sql->rowCount()>=1){
                return "Ok";
            }else{
                return $sql;
            }
        }
    }