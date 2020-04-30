<?php 
	class vistasModelo{
		protected function obtener_vistas_modelo($vistas){

			$listaBlanca=["login", "404", "admin","embarque", "categories", "client", "company", "home", "inventory", "trabajador", "products", "productores", "sales"];

			if(in_array($vistas, $listaBlanca)){
				if(is_file("./vistas/contenido/".$vistas."-view.php")){
					$contenido="./vistas/contenido/".$vistas."-view.php";
				}else{
					$contenido="login";
				}
			}elseif($vistas=="login"){
				$contenido="login";
			}elseif($vistas=="index"){
				$contenido="login";
			}else{
				$contenido="404";
			}
			return $contenido;
		}
	}