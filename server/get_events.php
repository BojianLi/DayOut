<?php
require_once('connectDB.php');
require_once('utility.php');

// foreach ($_GET as $param_name => $param_val) {
//     echo "Param: $param_name; Value: $param_val<br />\n";
// }


$success = isset($_GET['uid']) &&
		   isset($_GET['lat']) &&
		   isset($_GET['lon']);


$msg = '';
$data = array();

if ($success) {
	$events = array();
	$dists  = array();
	$query = "SELECT eid, ROUND(SQRT(POW(lat - ".$_GET['lat'].", 2) + POW(lon - ".$_GET['lon'].", 2)), 2) as distance FROM EVENTS ORDER BY distance";

	$result = $mysqli->prepare($query);

	if(!$result) {
		$msg = $mysqli->error;
		$success = False;
	}

	else {
		$result->execute();
		$result->bind_result($eid, $dist);
		while ($result->fetch()){
			array_push($events, $eid);
			array_push($dists, $dist);
		}
		$result->close();

		foreach ($events as $eid) {
		    // Organizer
			$organizer = array();
			$query = "SELECT C.uid, U.name, U.gender, C.date FROM CREATE_EVENT as C, USER as U WHERE C.uid = U.uid AND C.eid = ".$eid;

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
			$query = "SELECT name, locid, stime, etime, off_num, on_num, kind, info, cost, lat, lon FROM EVENTS where eid = ".$eid;

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
			$query = "SELECT content FROM TAG, OWN WHERE OWN.tid = TAG.tid AND OWN.eid = ".$eid;

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
			$query = "SELECT J.uid, U.name, U.gender, J.date FROM JOIN_EVENT as J, USER as U WHERE J.uid = U.uid AND J.eid = ".$eid;

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
			$query = "SELECT A.uid, U.name, U.gender, A.date FROM APPLY_EVENT as A, USER as U WHERE A.uid = U.uid AND A.eid = ".$eid;

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
			$query = "SELECT M.mid, M.content, U.name, M.date FROM MESSAGE as M, USER as U WHERE M.uid = U.uid AND M.eid = ".$eid;

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

			$photoUrl = 'http://api.tripadvisor.com/api/partner/2.0/location/'.$locid.'/photos?key=4FDDE1CDF4C2402980BABF84989B111D';			
			$photo = json_decode(file_get_contents($photoUrl), true);
			if ($photo['data'] == null) {
				$img = "";
			} else {
				$img = $photo["data"][0]["images"]["large"]["url"];//there are other images and the size of the image omitted.
			}
			if (!$img) {
				$img = "";
			}

			$lat2 = $lat * M_PI / 180;
		    $lon2 = $lon * M_PI / 180;
		    $lat1 = $_GET['lat'] * M_PI / 180;
		    $lon1 = $_GET['lon'] * M_PI / 180;
		    $distance = sqrt(pow($lat1 - $lat2, 2) + pow($lon1 - $lon2, 2)) * 3960;
			$distance = round($distance, 2);

			
			$metadata = array("name" => $name,
						  "locid" => $locid,
						  "distance" => $distance,
						  "img" => $img,
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

		//	var_dump($metadata);

			array_push($data, $metadata);
		}
	}
}
else {
	$msg = "GET failed";
}
if ($success) {


	$status = array("status"  => "OK",
					"data" => array("events" => $data));

	echo json_encode($status);
}
else {
	echo json_fail($msg);
}

?>