<?php
header("Content-type: application/json");
require_once('connectDB.php');
require_once('utility.php');

// var_dump($_GET);

// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['uid']) &&
		   isset($_GET['name']) &&
		   isset($_GET['locid']) &&
		   isset($_GET['stime']) &&
   		   isset($_GET['etime']) &&
		   isset($_GET['off_num']) &&
		   isset($_GET['on_num']) &&
		   isset($_GET['kind']) &&
		   isset($_GET['info']) &&
		   isset($_GET['cost']) &&
		   isset($_GET['lat']) &&
		   isset($_GET['lon']) &&
		   isset($_GET['tags']);

$msg = '';

if ($success) {
	$query = "INSERT INTO EVENTS 
			(name, locid, stime, etime, off_num, on_num, kind, info, cost, lat, lon) 
			VALUES (?,?,?,?,?,?,?,?,?,?,?)";
	$result = $mysqli->prepare($query);
		
	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	$result->bind_param('sissiissddd', $_GET['name'], $_GET['locid'], 
									   $_GET['stime'], $_GET['etime'], 
									   $_GET['off_num'], $_GET['on_num'], 
									   $_GET['kind'], $_GET['info'], 
									   $_GET['cost'], $_GET['lat'], 
									   $_GET['lon']);

	$result->execute();	
	$result->close();

	$eid = $mysqli->insert_id;

	echo "New eid: $eid";


	// Insert to create event

	$query = "INSERT INTO CREATE_EVENT (eid, uid) VALUES (?,?)";
	$result = $mysqli->prepare($query);
		
	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	$result->bind_param('ii', $eid, $_GET['uid']);
	$result->execute();	
	$result->close();



	// Adding Tags
	if ($_GET['tags'] != '') {

		$tags = explode(",",$_GET['tags']);

		foreach ($tags as $tag) {
			$query = "SELECT tid FROM TAG where content = '".$tag."'";

			$result = $mysqli->prepare($query);

			if(!$result) {
				$msg = $mysqli->error;
				$success = False;
			}
			else {
				$result->execute();
				$result->store_result();
				$result->bind_result($tid);
				$result->fetch();
				$rows = $result->num_rows;
				$result->close();


				if($rows != 0){
					echo "Found tid: $tid\n";
				}
				

				if($rows == 0) {
					$query = "INSERT INTO TAG (content) VALUES (?)";
					$result = $mysqli->prepare($query);

					if(!$result) {
						$msg = $mysqli->error;
						$success = False;
					} 

					else {
						$result->bind_param('s', $tag);
						$result->execute();
						$tid = $mysqli->insert_id;
						$result->close();	


						echo "Create new tid $tid\n";


					}
				}
		
				// Insert OWN table
				$query = "SELECT count(*) as c FROM OWN where eid = $eid AND tid = $tid";

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

						$result->bind_param('ii', $eid, $tid);
						$result->execute();	
						$result->close();

						echo "Insert eid: $eid, tid: $tid\n";

					}
				}
			}	
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