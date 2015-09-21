<?php
require_once('connectDB.php');
require_once('utility.php');

$success = isset($_GET['eid']) && isset($_GET['uid']);

$msg = '';

if($success) {
	$query = "DELETE FROM JOIN_EVENT WHERE eid = "
			.$_GET['eid']." AND uid = ".$_GET['uid'];
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