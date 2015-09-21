<?php
header("Content-type: application/json");

function sksort(&$array, $subkey="id", $sort_ascending=false) {

    if (count($array))
        $temp_array[key($array)] = array_shift($array);

    foreach($array as $key => $val){
        $offset = 0;
        $found = false;
        foreach($temp_array as $tmp_key => $tmp_val)
        {
            if(!$found and strtolower($val[$subkey]) > strtolower($tmp_val[$subkey]))
            {
                $temp_array = array_merge(    (array)array_slice($temp_array,0,$offset),
                                            array($key => $val),
                                            array_slice($temp_array,$offset)
                                          );
                $found = true;
            }
            $offset++;
        }
        if(!$found) $temp_array = array_merge($temp_array, array($key => $val));
    }

    if ($sort_ascending) $array = array_reverse($temp_array);

    else $array = $temp_array;
}


$searchLocation = $_GET['location'];
$latitude = $_GET['lat'];
$longitude = $_GET['lon'];
$searchLocation = str_replace(" ", "%20", $searchLocation);
$url = 'http://api.tripadvisor.com/api/partner/2.0/search/'.$searchLocation.'?key=4FDDE1CDF4C2402980BABF84989B111D';
$content = array();
$places = json_decode(file_get_contents($url), true);
$place = $places['attractions'];
foreach ($place as $info) {
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
    $lat2 = $info["latitude"] * M_PI / 180;
    $lon2 = $info["longitude"] * M_PI / 180;
    $lat1 = $latitude * M_PI / 180;
    $lon1 = $longitude * M_PI / 180;
    $distance = sqrt(pow($lat1 - $lat2, 2) + pow($lon1 - $lon2, 2)) * 3960;
	$distance = round($distance, 2);
	$arr = array(
		"locationID" => $locationID,
		"name" => $info["name"],
	    "address" => $info["address_obj"]["address_string"],
	    "distance"=> $distance,
	    "img" => $img,
	    "rating_img" =>$rating_img
	);
	array_push($content, $arr);
}
$place = $places['geos'];
foreach ($place as $info) {
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
	$rating_img = "";
    $lat2 = $info["latitude"] * M_PI / 180;
    $lon2 = $info["longitude"] * M_PI / 180;
    $lat1 = $latitude * M_PI / 180;
    $lon1 = $longitude * M_PI / 180;
    $distance = sqrt(pow($lat1 - $lat2, 2) + pow($lon1 - $lon2, 2)) * 3960;
	$distance = round($distance, 2);
	$arr = array(
		"locationID" => $locationID,
		"name" => $info["name"],
	    "address" => $info["address_obj"]["address_string"],
	    "distance"=> $distance,
	    "img" => $img,
	    "rating_img" =>$rating_img
	);
	array_push($content, $arr);
}
sksort($content, "distance", true);
$my_array = array(
	"status" => "OK",
	"data" => array(
		"places" => $content
	)
);
echo json_encode($my_array);
?>