<?php
 	$data = new StdClass();
	$fp = fopen($_POST['archivo'], "rb");
	$data->peso = fread($fp, filesize($_POST['archivo']));
	fclose($fp);
	echo json_encode($data);
	ob_flush();
	flush();
?>
