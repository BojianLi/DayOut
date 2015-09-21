<?php
$db_host="localhost";
//$db_host="52.26.60.242";
$db_user="wustl_inst";
$db_psw="wustl_pass";
$db_name="DAYOUT";
$mysqli = new mysqli($db_host, $db_user, $db_psw, $db_name);
if ($mysqli->connect_error) {
	echo "Connection Error: ".$mysqli->connect_error;
	exit;
}
?>