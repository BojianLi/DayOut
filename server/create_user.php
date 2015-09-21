<?php
require_once('connectDB.php');
require_once('utility.php');


// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['name']) &&
		   isset($_GET['gender']) &&
		   isset($_GET['password']);

$msg = '';

if ($success) {
	$query = "SELECT count(*) as c FROM USER where name = '".$_GET['name']."'";

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
			$query = "INSERT INTO USER 
					(name, gender, password) 
					VALUES (?,?,?)";
			$result = $mysqli->prepare($query);
				
			if(!$result) {
				$msg = $mysqli->error;
				$success = False;
			}

			$result->bind_param('sss', $_GET['name'], $_GET['gender'], $_GET['password']);

			$result->execute();	
			$result->close();
		}
		else {
			$msg = "User exists.";
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