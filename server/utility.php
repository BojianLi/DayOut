<?php

function json_success($data = array()) {
	$status = array("status"  => "OK");
	$data = array_merge($status,$data);
	return json_encode($data);
}

function json_fail($err) {
	$status = array("status"  => "ERROR",
					"error_msg" => $err);
	return json_encode($status);
}



?>