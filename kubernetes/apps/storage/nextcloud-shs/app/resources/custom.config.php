<?php
$CONFIG = array(
	'overwriteprotocol' => 'https',
	'overwrite.cli.url' => 'https://storage.hyde.services',
	'overwritehost' => 'storage.hyde.services',
	'check_data_directory_permissions' => false,
	'default_phone_region' => 'AU',
	'trusted_proxies' => array(
		0 => '127.0.0.1',
		1 => '10.0.0.0/8',
	),
	'trusted_domains' => array(
		0 => '127.0.0.1',
		1 => 'storage.hyde.services',
	),
	'simpleSignUpLink.shown' => false,
	'cache_path' => '/cache',
	'forwarded_for_headers' => array('HTTP_X_FORWARDED_FOR'),
	'maintenance_window_start' => 100,
);
