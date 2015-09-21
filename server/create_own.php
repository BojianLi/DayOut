<?php
require_once('connectDB.php');
require_once('utility.php');


// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['eid']) &&
		   isset($_GET['tid']);

$msg = '';

if ($success) {
	$query = "SELECT count(*) as c FROM OWN where eid = ".$_GET['eid']." AND tid = ".$_GET['tid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}
	else {
		$result->execute();
		$result->bind_result($count);
		$result->fetch();
		$result->close();

		if($count == 0) {
			$query = "INSERT INTO OWN (eid, tid) VALUES (?,?)";
			$result = $mysqli->prepare($query);
				
			if(!$result) {
				$msg = $mysqli->error;
				$success = False;
			}

			$result->bind_param('ii', $_GET['eid'], $_GET['tid']);
			$result->execute();	
			$result->close();
		}
		else {
			$msg = "Already owned.";
			$success = False;
		}
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