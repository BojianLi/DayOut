<?php
require_once('connectDB.php');
require_once('utility.php');


// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['content']);

$msg = '';

if ($success) {
	$query = "SELECT count(*) as c FROM TAG where content = '".$_GET['content']."'";

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
			$query = "INSERT INTO TAG (content) VALUES (?)";
			$result = $mysqli->prepare($query);

			if(!$result) {
				$msg = $mysqli->error;
				$success = False;
			} 

			else {
				$result->bind_param('s', $_GET['content']);
				$result->execute();
				$result->close();
			}
		}
		else{
			$msg = "Tag exists.";
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