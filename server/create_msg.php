<?php
require_once('connectDB.php');
require_once('utility.php');


// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['content']) &&
		   isset($_GET['eid']) &&
		   isset($_GET['uid']);

$msg = '';

if ($success) {
	$query = "INSERT INTO MESSAGE (content, eid, uid) VALUES (?,?,?)";
	$result = $mysqli->prepare($query);
		
	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	$result->bind_param('sii', $_GET['content'], $_GET['eid'], $_GET['uid']);

	$result->execute();	
	$result->close();
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