<?php


    class EplPrinter{
        //Variables para lineas
        public static $HORIZONTAL = 'horizontal';
        public static $VERTICAL = 'vertical';

    /**
     * Constructor
     */
    public function __construct() {
        
    }

    /**
     * Envia comandos EPL al dispositivo indicado
     * 
     * @param string $label comandos
     * @param string $printer nombre de la impresora
     * @param boolean $printD si desea imprimir en el dispositivo
     * @param boolean $debug si desea imprimir información de la configuración
     */

    public function send($label, $printer, $printD = true, $debug = false) {
                        
        // Create a temp file
        $file = tempnam(sys_get_temp_dir(), 'lbl');
        
        // Open the file for writing
        $handle = fopen($file, "w");
        fwrite($handle, $label);
        fclose($handle); // Close the file        

        if ($printD) {
            // Print the file
            $print =  exec('print /d:"\\\%COMPUTERNAME%\\' . $printer . '" "' . $file . '"');
        }        
        
        // Delete the file
        $delete =  unlink($file);

        if ($debug) {
            echo "<h2>Para desactivar el depurador, cambiar a false en la llamas de la función: send</h2>";
            echo ("<h4>Comandos ZPL: ".$label."</h4>");
            echo ("<h4>Archivo temporal eliminado: ".$delete."</h4>");

            if ($printD) {
                echo ("<h4>Impresión: ".$print."</h4>");
            }else{
                echo ("<h4>Impresión: La impresión esta desactivada (habilitar en la función send).</h4>");
            }

                        
        }

    }
    
    /**
     * Add the label header and footer details
     * 
     * @param string $data The label data
     * @param int $quantity The quantity of labels to print
     * @return string
     */
    public function compile($data, $quantity = 1){
        // Create the label header
        $compiled = '' . (new EplPrinter())->_eol();
        //$compiled .= 'N' . (new EplPrinter())->_eol();
        
        //[q] Set the label width to 609 dots (3 inch label x 203 dpi = 609 dots wide).
        //$compiled = 'q812' . $this->_eol();
        
        // Append the data
        $compiled .= $data;

        // Append the label footer
         $compiled .= ',' . (int) $quantity . (new EplPrinter())->_eol();
        //$compiled .= 'P1,' . (int) $quantity . (new EplPrinter())->_eol();
        
        return $compiled;
    }
    
    /**
     * Write a string of ascii characters
     * 
     * @param string $value The string of text
     * @param int $xStart The horizontal start position
     * @param int $yStart The vertical start position
     * @param int $font The font selection (1-5)
     * @param boolean $reverse Wether to reverse the text to white on black
     * @param int $rotation The rotation of the text
     *                      0 = Normal (No rotation)
     *                      1 = 90 Degrees
     *                      2 = 180 Degrees
     *                      3 = 270 Degrees
     * @param int $xMultiplier
     * @param int $yMultiplier
     * @return string
     */
    public function writeString($value, $xStart, $yStart, $font, $reverse = false, $rotation = 0, $xMultiplier = 1, $yMultiplier = 1){
        $command = 'A';

        // Check for the reverse parameter
        // Reverse = N (Normal) or R (Reversed)
        $style = 'N';
        if ((bool) $reverse) {
            $style = 'R';
        }

        return (new EplPrinter())->writeLine($command, array(
            (int) $xStart,
            (int) $yStart,
            (int) $rotation,
            $font,
            (int) $xMultiplier,
            (int) $yMultiplier,
            $style,
            '"' . $value . '"'
        ));
    }

    /**
     * Write a barcode
     * 
     * @param string $value The barcode string
     * @param int $xStart The horizontal start position
     * @param int $yStart The vertical start position
     * @param int $height
     * @param string $type
     * @param boolean $readable
     * @param int $rotation
     * @param int $narrowBar
     * @param int $wideBar
     * @return string
     */
    public function drawBarcode($value, $xStart, $yStart, $height, $type = 3, $readable = true, $rotation = 0, $narrowBar = 2, $wideBar = 3){
        $command = 'B';

        // Check for the human readable parameter
        // Human Readable = B (Yes) or N (No)
        $humanReadable = 'B';
        if (!(bool) $readable) {
            $humanReadable = 'N';
        }

        return (new EplPrinter())->writeLine($command, array(
            (int) $xStart,
            (int) $yStart,
            (int) $rotation,
            $type,
            (int) $narrowBar,
            (int) $wideBar,
            (int) $height,
            $humanReadable,
            '"' . $value . '"'
        ));
    }
    
    /**
     * Draw a black box
     * 
     * @param int $xStart The horizontal start position
     * @param int $yStart The vertical start position
     * @param int $xEnd The horizontal end position
     * @param int $yEnd The vertical end position
     * @param int $thickness The thickness in dots
     * @return string
     */
    public function drawBox($xStart, $yStart, $xEnd, $yEnd, $thickness = 2){
        $command = 'X';

        return $this->writeLine($command, array(
            (int) $xStart,
            (int) $yStart,
            (int) $thickness,
            (int) $xEnd,
            (int) $yEnd,
        ));
    }

    /**
     * Draw a line in either black or white
     * 
     * @see $this->line()
     * @param int $xStart The horizontal start position
     * @param int $yStart The vertical start position
     * @param int $length The length of the line in dots
     * @param int $thickness The thickness of the line in dots
     * @param int $orientation The orientation of the line [vertical|horizontal]
     * @param boolean $black Whether to print a black or white line (white only appears when printing over another line)
     * @param boolean $exclude Whether to exclude colour when overlapping other objects (i.e. when printing over another black line this line will be white)
     * @return string
     */
    public function drawLine($xStart, $yStart, $length, $thickness = 2, $orientation = 'vertical', $black = true, $exclude = false)
    {
        // Check the orientation and create the correct thickness and length
        if ('horizontal' == $orientation) {
            $xLength = $length;
            $yLength = $thickness;
        } else {
            $yLength = $length;
            $xLength = $thickness;
        }

        // Determine the correct line drawing method
        // TODO: Need to work on Black and white and exclusive lines.
        $command = 'LO';
        if ($exclude) {
            $command = 'LE';
        } elseif (!$black) {
            $command = 'LW';
        }

        // Create the line
        return (new EplPrinter())->writeLine($command, array(
            (int) $xStart,
            (int) $yStart,
            (int) $xLength,
            (int) $yLength
        ));
    }

    /**
     * Draw a diagonal line
     * 
     * @param int $xStart The horizontal start position
     * @param int $yStart The vertical start position
     * @param int $yEnd The vertical end position
     * @param int $length The length of the line in dots
     * @param int $thickness The thickness of the line in dots
     * @return string
     */
    public function drawDiagonalLine($xStart, $yStart, $yEnd, $length, $thickness = 2)
    {

    }

    /**
     * Create a line of code
     * 
     * @param string $command The command
     * @param array $options The options to write
     * @return string
     */
    protected function writeLine($command, $options)
    {
        return $command . implode(',', $options) . $this->_eol();
    }

    /**
     * Return the correct end of line characters
     * 
     * @return string
     */
    protected function _eol()
    {
        return PHP_EOL;
    }


}


?>