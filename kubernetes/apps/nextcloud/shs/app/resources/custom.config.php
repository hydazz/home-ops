<?php
$CONFIG = array(
	'overwriteprotocol' => 'https',
	'overwrite.cli.url' => 'https://storage.${D_HS}',
	'overwritehost' => 'storage.${D_HS}',
	'check_data_directory_permissions' => false,
	'default_phone_region' => 'AU',
	'enable_previews' => false,
	'trusted_proxies' => array(
		0 => '127.0.0.1',
		1 => '10.0.0.0/8',
	),
	'trusted_domains' => array(
		0 => '127.0.0.1',
		1 => 'storage.${D_HS}',
	),
	'filesystem_check_changes' => 1,
	'simpleSignUpLink.shown' => false,
	'cache_path' => '/cache',
	'forwarded_for_headers' => array('HTTP_X_FORWARDED_FOR'),
);
