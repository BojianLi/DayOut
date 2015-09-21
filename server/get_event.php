<?php
require_once('connectDB.php');
require_once('utility.php');

// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['uid']) && isset($_GET['eid']);

$msg = '';

if ($success) {


    // Organizer
	$organizer = array();
	$query = "SELECT C.uid, U.name, U.gender, C.date FROM CREATE_EVENT as C, USER as U WHERE C.uid = U.uid AND C.eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($uid, $name, $gender, $date);
		$result->fetch();
		$organizer = array("uid"  => $uid,
						   "name" => $name,
						   "gender" => $gender,
					  	   "apply_time" => $date);
		$result->close();
	}


	// EVENT Info
	$query = "SELECT name, locid, stime, etime, off_num, on_num, kind, info, cost, lat, lon FROM EVENTS where eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}
	else {
		$result->execute();
		$result->bind_result($name, $locid, $stime, $etime, $off_num, $on_num, $kind, $info, $cost, $lat, $lon);
		$result->fetch();
		$result->close();
	}

	// var_dump($locid, $stime, $etime, $off_num, $on_num, $kind, $info, $cost, $lat, $lon);

	// TAGS
	$tags = array();
	$query = "SELECT content FROM TAG, OWN WHERE OWN.tid = TAG.tid AND OWN.eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($tag);
		while($result->fetch()) {
			$tag = array("name" => $tag);
			array_push($tags, $tag);
		}
		$result->close();
	}

	// var_dump($tags);

	// JOINED USER
	$joined_users = array();
	$query = "SELECT J.uid, U.name, U.gender, J.date FROM JOIN_EVENT as J, USER as U WHERE J.uid = U.uid AND J.eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($uid, $name, $gender, $date);
		while($result->fetch()) {
			$user = array("uid"  => $uid,
							"name" => $name,
							"gender" => $gender,
							"join_time" => $date);
			array_push($joined_users, $user);
		}
		$result->close();
	}

	
	// APPLIED USER
	$applied_users = array();
	$query = "SELECT A.uid, U.name, U.gender, A.date FROM APPLY_EVENT as A, USER as U WHERE A.uid = U.uid AND A.eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($uid, $name, $gender, $date);
		while($result->fetch()) {
			$user = array("uid"  => $uid,
						  "name" => $name,
						  "gender" => $gender,
						  "apply_time" => $date);
			array_push($applied_users, $user);
		}
		$result->close();
	}


	// Messages
	$messages = array();
	$query = "SELECT M.mid, M.content, U.name, M.date FROM MESSAGE as M, USER as U WHERE M.uid = U.uid AND M.eid = ".$_GET['eid'];

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($mid, $msgcontent, $user, $date);
		while ($result->fetch()) {
			$msg = array("mid"  => $mid,
						 "name" => $user,
						 "time" => $date,
						 "content" => $msgcontent);
			array_push($messages, $msg);
		}
		$result->close();
	}

	
	$data = array("name" => $name,
				  "locid" => $locid,
				  "distance" => 0.5,
				  "img" => "http://media-cdn.tripadvisor.com/media/photo-w/06/60/30/a8/beautiful-day-in-august.jpg",
				  "description" => $info,
				  "start_time" => $stime,
				  "end_time" => $etime,
				  "organizer" => $organizer,
				  "available" => $off_num,
				  "total" => $on_num,
				  "tags" => $tags,
				  "joined_users" => $joined_users,
				  "applied_user" => $applied_users,
				  "messages" => $messages);
}
else {
	$msg = "GET failed";
}
if ($success) {
	echo json_success($data);
}
else {
	echo json_fail($msg);
}

?>