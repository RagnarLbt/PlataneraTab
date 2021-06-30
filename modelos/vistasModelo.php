<?php 
	class vistasModelo{
		protected function obtener_vistas_modelo($vistas){

			$listaBlanca=["login", "404", "admin","embarque", "company", "trabajador", "productores", "gastos", "tablero", "consultas", "banco", "update"];

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
				$contenido="./vistas/contenido/404-view.php";
			}
			return $contenido;
		}

		protected function obtener_js_modelo($vistas){

			$listaBlanca=["login", "404", "admin","embarque", "company", "trabajador", "productores", "gastos", "tablero", "consultas", "banco", "update"];

			if(in_array($vistas, $listaBlanca)){
				if(is_file("./vistas/js/".$vistas."-vue.js")){
					$contenido="./vistas/js/".$vistas."-vue.js";
				}else{
					$contenido="./vistas/js/login-vue.js";
				}
			}elseif($vistas=="login"){
				$contenido="./vistas/js/login-vue.js";
			}elseif($vistas=="index"){
				$contenido="./vistas/js/login-vue.js";
			}else{
				$contenido="./vistas/js/login-vue.js";
			}
			return $contenido;
		}
	}