<?php
	if ($peticionAjax) {
		require_once"../core/mainModel.php";
	} else {
		require_once "./core/mainModel.php";
	}

	class loginModelo extends mainModel{
		
		protected function iniciar_sesion_modelo($datos){
			$sql=mainModel::conectar()->prepare("SELECT id, user, nombre, tipo, estado, genero FROM `usuario` where user=:Usuario and password=:Contra AND estado='ALTA'");
			$sql->bindParam(":Usuario", $datos['usuario']);
			$sql->bindParam(":Contra", $datos['contra']);
			$sql->execute();
			return $sql;
		}

		protected function iniciar_sesion_admin($datos){
			$sql=mainModel::conectar()->prepare("SELECT id, user, nombre, tipo, estado FROM `usuario` where user=:Usuario and password=:Contra AND estado='ALTA' AND tipo=1");
			$sql->bindParam(":Usuario", $datos['usuario']);
			$sql->bindParam(":Contra", $datos['contra']);
			$sql->execute();
			return $sql;
		}

		protected function finalizar_sesion_modelo($datos){
			if ($datos['usuario']!="" && $datos['token_p']==$datos['token']) {
				
				session_unset();
				session_destroy();
				$respuesta="true";
				
			} else {
				$respuesta="false";
			}

			return $respuesta;
		}

		
	}