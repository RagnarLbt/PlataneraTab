<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
    }
    
    class administradorModelo extends mainModel{

       protected function agregar_admin_modelo($datos){
			$sql=mainModel::conectar()->prepare("INSERT INTO `usuario`(`user`, `password`, `nombre`, `genero`, `tipo`, `estado`) VALUES (:usuario, :pass, :nom, :gen, :tip, 'ALTA')");
            $sql-> bindParam(":usuario", $datos['User']);
             $sql-> bindParam(":pass", $datos['Password']);
             $sql-> bindParam(":nom", $datos['Nombre']);
             $sql-> bindParam(":gen", $datos['Genero']);
             $sql-> bindParam(":tip", $datos['Tipo']);
           
             $sql->execute();
             return $sql;
        }

        protected function eliminar_admin_modelo($id){
            $sql=mainModel::conectar()->prepare("call deleteUsuario(:id)");
            $sql->bindParam(":id", $id['Id']);
            $sql-> execute();
            return $sql;
        }
        protected function  lista_admin_modelo(){
            $sql=mainModel::conectar()->prepare("SELECT `id`, `user`, `password`, `nombre`, `genero`, `tipo`, `estado` FROM `usuario`");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);

        }

        protected function buscar_admin_modelo(){
            $sql=mainModel::conectar()->prepare("call verlistaUsuario()");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }




    }