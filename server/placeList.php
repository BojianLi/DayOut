<?php
header("Content-type: application/json");
$latitude = $_GET['lat'];
$longitude = $_GET['lon'];
$url = 'http://api.tripadvisor.com/api/partner/2.0/map/'.$latitude.','.$longitude.'/attractions?key=4FDDE1CDF4C2402980BABF84989B111D';
$json = json_decode(file_get_contents($url), true);
$json = $json["data"];
$content = array();
foreach ($json as $info) {
	$locationID = $info["location_id"];
	$photoUrl = 'http://api.tripadvisor.com/api/partner/2.0/location/'.$locationID.'/photos?key=4FDDE1CDF4C2402980BABF84989B111D';
	$photo = json_decode(file_get_contents($photoUrl), true);
	if ($photo['data'] == null) {
		$img = "";
	} else {
		$img = $photo["data"][0]["images"]["large"]["url"];//there are other images and the size of the image omitted.
	}
	if (!$img) {
		$img = "";
	}
	$rating_img = $info["rating_image_url"];
	if (!$rating_img) {
		$rating_img = "";
	}
	$arr = array(
		"locationID" => $locationID,
		"name" => $info["name"],
	    "address" => $info["address_obj"]["address_string"],
	    "distance"=> $info["distance"],
	    "img" => $img,
	    "rating_img" =>$rating_img
	);
	array_push($content, $arr);
}
$my_array = array(
	"status" => "OK",
	"data" => array(
		"places" => $content
	)
);
echo json_encode($my_array);
?>