# The hash key is the section name and sub hashes are item and value configs for that specified item in the hash section.

$mysql_options = {
  'client' => {
  'socket'         => '/run/mysqld/mysqld.sock',
  },
  'mysqld' => {
    'bind-address' => '0.0.0.0',
  },
}


# Root password for MySQL. Root is only log in-able from localhost.

$mysqlrootpwd = 'qHtPTJtFyH*HJZ$6#@aC4nB#@!JEGS'


# List of databases to create and with the corresponding configuration options.
# Hash key is the name of the database (string).
# First array item is the name of the corresponding DB user.
# Second array item is the password for the corresponding DB user.
# The third array item is the host name that is allowed to access thh database.

$databases = {
'wordpress'         => ['elliot_wp', 'W*xAm^6$w45ZN2hNjJk7Uh9QcsVM%%', '10.0.0.35' ],
'nextcloud'         => ['elliot_nc', 'Y!6kZBqudU5FvZjM*dGu#Rja^uTWPt', '10.0.0.35' ],
'huffdaddy'         => ['steve_wp', 'Rqa$#PYwESX##3JjfPjBv9C2EnVh7B', '10.0.0.35' ],
'etest1'            => ['elliot_tst1', 'JNDxY!!FTwbengN86kdew5ucNZMGu%', '10.0.0.35' ],
'etest2'            => ['elliot_tst2', 'p5VT&62Eh5@HbCRMFX^#ehaNmVmy*u', '10.0.0.35' ],
'etest3'            => ['elliot_tst3', 'vSPxZke2!7FqpQQcH7W!Xm6U9n!!85', '10.0.0.35' ],
'minigames'         => ['elliot_mini', 'w&HXy62BkRCva8Ng5jBQ@KD3jX$cWA', '10.0.0.50' ],
'minigames_legacy'  => ['elliot_mini_legacy', 'VNDxtu32RXKzandfz#ahWpJ#*Sm2!S', '10.0.0.50' ],
'worldguard'        => ['elliot_wg', 'C2RT@sJmE4hg94nNz8E4mfSbNbGX3%', '10.0.0.50' ],
'worldguard_legacy' => ['elliot_wg_legacy', 'GAhQ2mKdP2GP*f8J692bQ*H35pb#Y6', '10.0.0.50' ],
'spigot'            => ['elliot_spigot', 'DDA8Xvk^VhuXuJ&En*hwYJYahNB4aZ', '10.0.0.50' ],
'phpmyadmin'        => ['pma', 'bzn8TKjXfdcKEzTcUMG42f^Ux6F$!S', '192.168.0.20' ],
}

# TODO
# Enabling this setting will enforece teh host settings on the databse.
# Keeping this disabled will allow hosts settings to stack:
# If the settings are changed the old settings will be retained in adition to the new ones.

$dbpermissionspurge = false