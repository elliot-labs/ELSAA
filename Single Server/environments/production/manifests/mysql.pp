#
# MySQL Defs
#

if $mysqlToggle {

# MySQL server setup
class { '::mysql::server':
  root_password           => $mysqlRootPWD,
  remove_default_accounts => true,
  override_options        => $mysqlOptions,
}

# Automatically create databases programmatically.
$databases.each | String $dbName, Array $dbMetadata | {

  # Database creation and configuration.
  mysql::db { $dbName:
    user     => $dbMetadata[0],
    password => $dbMetadata[1],
    host     => $dbMetadata[2],
    charset  => 'utf8mb4',
    collate  => 'utf8mb4_general_ci',
  }
}

}