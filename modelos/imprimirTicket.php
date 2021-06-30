<?php
	if ($peticionAjax) {		
		require '../vistas/assets/pdf/EplPrinter.php';
	} else {
		require './vistas/assets/pdf/EplPrinter.php';
	}

	class imprimirTicket{

		public function imprimir($datos){
			//Instanciamos de la clase EplPrinter.php
			$epl = new EplPrinter();
			//Escribimos el nombre de la impresora tal cual este compartida.
			$impresora = 'Xprinter XP-450B';

			$texto2 = $datos['PRODUCTOR']." ".$datos['DIA'];//PRODUCTOR Y DIA 
			$texto3 = $datos['BOLSERO']." - ".$datos['PELADOR'];//BOLSERO-PELADOR
			$texto4 = "#".$datos['BOLSA'];//# BOLSA
			$texto6 = $datos['FECHA'];//HORA Y FECHA


			$etiqueta = "^XA
			^CF0,30
			^FO525,10^FD".$texto6."^FS
			^CF0,235
			^FO220,90^FD".$texto2."^FS
			^CF0,40
			^FO150,420^FD".$texto3."^FS
			^FO540,420^FD".$texto4."^FS
			^XZ";

			$epl::send($epl::compile($etiqueta, 1), $impresora, true, false);

			/*$etiqueta = $epl::writeString($texto1, 10, 10, 1, false, 0, 3, 3);
			$etiqueta .= $epl::drawLine(5, 75, 800, 10, EplPrinter::$HORIZONTAL, true, false);    
			$etiqueta .= $epl::writeString($texto2, 130, 95, 5, false, 0, 2, 2);
			$etiqueta .= $epl::writeString($texto3, 50, 210, 4, false, 0, 3, 3);
			$etiqueta .= $epl::writeString($texto4, 130, 310, 4, false, 0, 3, 3);
    		//$etiqueta .= $epl::writeString($texto5, 240, 405, 2, false, 0, 2, 2);
			$etiqueta .= $epl::writeString($texto6, 2, 450, 3, false, 0, 1, 1);*/  

		}
	}