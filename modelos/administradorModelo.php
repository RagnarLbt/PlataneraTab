<?php 
	if ($peticionAjax) {
		require_once "../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
    }
    
    class administradorModelo extends mainModel{

       protected function agregar_admin_modelo($datos){
			$sql=mainModel::conectar()->prepare("INSERT INTO `usuario`(`user`, `password`, `nombre`, `genero`, `tipo`, `estado`) VALUES (:usu, :pass, :nom, :gen, :tip, 'ALTA')");
            $sql->bindParam(":usu", $datos['User']);
            $sql->bindParam(":pass", $datos['Password']);
            $sql->bindParam(":nom", $datos['Nombre']);
            $sql->bindParam(":gen", $datos['Genero']);
            $sql->bindParam(":tip", $datos['Tipo']);

            $sql->execute();
            return $sql;
        }

        protected function eliminar_admin_modelo($id){
            $sql=mainModel::conectar()->prepare("DELETE FROM `usuario` WHERE id=:id");
            $sql->bindParam(":id", $id);
            $sql->execute();
            return $sql;
        }
        protected function  lista_admin_modelo(){
            $sql=mainModel::conectar()->prepare("SELECT * FROM `usuario` WHERE id!=10000");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);

        }

        protected function lista_capturista_modelo(){
            $sql=mainModel::conectar()->prepare("SELECT * FROM `usuario` WHERE tipo=2");
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }

        protected function editar_admin_modelo($datos){
            $sql=mainModel::conectar()->prepare("UPDATE `usuario` SET `user`=:usuario,`nombre`=:nom,`genero`=:gen,`tipo`=:tip WHERE id= :id");
            $sql-> bindParam(":id", $datos ['Id']);
            $sql-> bindParam(":usuario", $datos ['User']);
            $sql-> bindParam(":nom", $datos ['Nombre']);
            $sql-> bindParam(":gen", $datos ['Genero']);
            $sql-> bindParam(":tip", $datos ['Tipo']);
            $sql-> execute();
            return $sql->fetchAll(PDO::FETCH_ASSOC);
        }




    }