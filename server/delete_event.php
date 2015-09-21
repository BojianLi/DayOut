<?php
require_once('connectDB.php');
require_once('utility.php');

$success = isset($_GET['eid']);

$msg = '';

if($success) {
	$query = "DELETE FROM EVENTS WHERE eid = ".$_GET['eid'];
	if(!$mysqli->query($query)) {
		$msg = $mysqli->error;
		$success = False;
	}
}
else {
	$msg = "GET failed";
}

if ($success) {
	echo json_success();
}
else {
	echo json_fail($msg);
}

?>