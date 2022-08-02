#
# MySQL Defs
#

# MySQL server setup
class { '::mysql::server':
  root_password           => $mysqlrootpwd,
  remove_default_accounts => true,
  override_options        => $mysql_options,
}

# Automatically create databases programitically.
$databases.each | String $dbname, Array $dbmetadata | {

  # MariaDB creation and configuration.
  mysql::db { $dbname:
    user     => $dbmetadata[0],
    password => $dbmetadata[1],
    host     => $dbmetadata[2],
    charset  => 'utf8mb4',
    collate  => 'utf8mb4_general_ci',
  }
}