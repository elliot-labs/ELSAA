# Required Modules:
#
#
# puppetlabs-apt
# puppetlabs-mysql
# puppetlabs-apache
# puppetlabs-motd
# puppetlabs-stdlib
# garethr-docker
#
#


#
# Script Variables
#

# Lists the packages that need to be installed.
$packages = [ 'unattended-upgrades', 'libapache2-mod-fastcgi', 'php7.0-fpm', 'php7.0', 'python-letsencrypt-apache', 'php7.0-mysql',
'php7.0-zip', 'php7.0-gd', 'php7.0-mbstring', 'php7.0-curl', 'php7.0-xml', 'php7.0-tidy', 'php-apcu', 'php7.0-json',
'php-imagick', 'php7.0-intl', 'php7.0-mcrypt', 'ddclient', 'ffmpeg', 'syncthing' ]

# System User
$user = '**REMOVED**'

# System Group
$group = '**REMOVED**'


#
# APT Repository defs
#

include apt

# Add Syncthing Repository to APT
apt::source { 'syncthing':
  comment  => 'This is the stable repository for syncthing.',
  location => 'https://apt.syncthing.net/',
  release  => 'syncthing',
  repos    => 'stable',
  key      => {
    id     => '37C84554E7E0A261E4F76E1ED26E6ED000654A3E',
    source => 'https://syncthing.net/release-key.txt',
  },
} ->

#
# install packages
#

# Takes the previous list, installs and or updates the packages to the latest version(s).
package { $packages: ensure => 'latest' }

# Service declaration, declared to make sure that it is restarted upon config change.
service { 'php-fpm':
  name   => 'php7.0-fpm',
  ensure => running,
  enable => true,
}


#
# Auto upgrades for OS
#

# Select sources for all packages.
file_line  {'Unattended_Upgrades source_updates':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/50unattended-upgrades',
  line   => '      "${distro_id}:${distro_codename}-updates";',
  match  => '^//      "${distro_id}:${distro_codename}-updates";',
}

# Select sources for all packages.
file_line  {'Unattended_Upgrades source_backports':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/50unattended-upgrades',
  line   => '      "${distro_id}:${distro_codename}-backports";',
  match  => '^//      "${distro_id}:${distro_codename}-backports";',
}

# Break up updates into smaller segments to allow for the ability to reboot whenever.
file_line  {'Unattended_Upgrades minimal_segments':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/50unattended-upgrades',
  line   => 'Unattended-Upgrade::MinimalSteps "true";',
  match  => '^//Unattended-Upgrade::MinimalSteps',
}

# Allows the automatic reboot of system if needed.
file_line  {'Unattended_Upgrades auto_reboot':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/50unattended-upgrades',
  line   => 'Unattended-Upgrade::Automatic-Reboot "true";',
  match  => '^//Unattended-Upgrade::Automatic-Reboot "',
}

# Sets the time when the system should be automatically rebooted if needed.
file_line  {'Unattended_Upgrades reboot_time':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/50unattended-upgrades',
  line   => 'Unattended-Upgrade::Automatic-Reboot-Time "22:00";',
  match  => '^//Unattended-Upgrade::Automatic-Reboot-Time',
}

# Automatically updates APT lists every day
file_line  {'Unattended_Upgrades APT Update':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/10periodic',
  line   => 'APT::Periodic::Update-Package-Lists "1";',
  match  => '^APT::Periodic::Update-Package-Lists',
}

# Automatically downloads updates
file_line  {'Unattended_Upgrades APT Download':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/10periodic',
  line   => 'APT::Periodic::Download-Upgradeable-Packages "1";',
  match  => '^APT::Periodic::Download-Upgradeable-Packages',
}

# Automatically upgrades the packages.
file_line  {'Unattended_Upgrades APT Install':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/10periodic',
  line   => 'APT::Periodic::Unattended-Upgrade "1";',
  match  => '^APT::Periodic::Unattended-Upgrade',
}

# Automatically cleans up old files
file_line  {'Unattended_Upgrades APT Autoclean':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/10periodic',
  line   => 'APT::Periodic::AutocleanInterval "7";',
  match  => '^APT::Periodic::AutocleanInterval',
}


#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Chris Perdue's archive server.\n\nNextCloud is automatically maintained, you better have\na good excuse to be in here...\n\n",
}


#
# Docker Defs
#

# Installs and configures the docker engine
class { 'docker':
  manage_kernel    => false,
}

# Downloads the Collabora/Code image
docker::image { 'collabora/code':
  image_tag => 'latest',
  } ->

# Runs the collabora container. After image creation.
docker::run { 'collabora_code':
  image            => 'collabora/code',
  ports            => ['127.0.0.1:9980:9980'],
  env              => ['domain=cloud\.perduecloud\.com'],
  restart_service  => true,
  pull_on_start    => true,
  extra_parameters => [ '--cap-add MKNOD', '-t'],
}


#
# MySQL Defs
#

# MySQL server setup
class { '::mysql::server':
  root_password           => '**REMOVED**',
  remove_default_accounts => true,
}

# NextCloud DB creation
mysql::db { 'nextcloud':
  user     => '**REMOVED**',
  password => '**REMOVED**',
  host     => 'localhost',
  charset  => 'utf8mb4',
  collate  => 'utf8mb4_general_ci',
}


#
# Cron Def
#

# Autorun Puppet at 9pm every day.
cron { 'PuppetApply':
  ensure  => present,
  command => '/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests',
  user    => 'root',
  hour    => 21,
  minute  => absent,
}

# Auto renew SSL certificates. Late - 7PM
cron { 'LetsEncrypt_Late':
  ensure  => present,
  command => 'letsencrypt renew',
  user    => 'root',
  hour    => 19,
  minute  => absent,
}

# Auto renew SSL certificates. Early - 7AM
cron { 'LetsEncrypt_Early':
  ensure  => present,
  command => 'letsencrypt renew',
  user    => 'root',
  hour    => 7,
  minute  => absent,
}


#
# Apache Defs
#

# Initializes apache
class { 'apache':
  mpm_module    => event,
  default_vhost => false,
}

# Enable apache mods
class { 'apache::mod::rewrite':}
class { 'apache::mod::actions':}
class { 'apache::mod::proxy':}
class { 'apache::mod::proxy_http':}
class { 'apache::mod::proxy_wstunnel':}
class { 'apache::mod::proxy_fcgi':}
class { 'apache::mod::ssl': }
class { 'apache::mod::expires': }
class { 'apache::mod::headers': }
class { 'apache::mod::fastcgi': }

# Folder permissions for NextCloud
file { '/var/www/NextCloud' :
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
}

# Automatically sets php-fpm for the correct user.
file_line  {'PHP-FPM User':
  ensure => present,
  notify  => Service['php-fpm'],
  path   => '/etc/php/7.0/fpm/pool.d/www.conf',
  line   => "user = $user",
  match  => '^user = ',
}

# Automatically sets php-fpm for the correct group.
file_line  {'PHP-FPM Group':
  ensure => present,
  notify  => Service['php-fpm'],
  path   => '/etc/php/7.0/fpm/pool.d/www.conf',
  line   => "group = $group",
  match  => '^group = ',
}

# The NextCloud virtual host
apache::vhost { 'cloud.perduecloud.com':
  servername      => 'cloud.perduecloud.com',
  port            => '80',
  docroot         => '/var/www/NextCloud',
  docroot_owner   => $user,
  docroot_group   => $group,
  override        => ['all'],
  custom_fragment => '
  <Directory /usr/lib/cgi-bin>
    Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
    AddHandler php7-cloud-fcgi .php
    Action php7-cloud-fcgi /php7-cloud-fcgi virtual
    Alias /php7-cloud-fcgi /usr/lib/cgi-bin/php7-cloud-fcgi
    FastCgiExternalServer /usr/lib/cgi-bin/php7-cloud-fcgi -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
}

# The SSL virtual host for NextCloud
apache::vhost { 'cloud.perduecloud.com ssl':
  servername      => 'cloud.perduecloud.com',
  port            => '443',
  docroot         => '/var/www/NextCloud',
  docroot_owner   => $user,
  docroot_group   => $group,
  override        => ['all'],
  custom_fragment => '
  Header always set Strict-Transport-Security "max-age=15552000; preload"
  <Directory /usr/lib/cgi-bin>
    Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
    AddHandler php7-cloud-ssl-fcgi .php
    Action php7-cloud-ssl-fcgi /php7-cloud-ssl-fcgi virtual
    Alias /php7-cloud-ssl-fcgi /usr/lib/cgi-bin/php7-cloud-ssl-fcgi
    FastCgiExternalServer /usr/lib/cgi-bin/php7-cloud-ssl-fcgi -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
  ssl        => true,
  ssl_cert   => '/etc/letsencrypt/live/cloud.perduecloud.com/fullchain.pem',
  ssl_key    => '/etc/letsencrypt/live/cloud.perduecloud.com/privkey.pem',
  additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
}

# The SSL virtual host for NextCloud online office system.
apache::vhost { 'office.perduecloud.com':
  servername                => 'office.perduecloud.com:443',
  port                      => '443',
  docroot                   => false,
  manage_docroot            => false,
  allow_encoded_slashes     => 'nodecode',
  ssl_proxyengine           => true,
  ssl_proxy_verify          => 'none',
  ssl_proxy_check_peer_cn   => 'off',
  ssl_proxy_check_peer_name => 'off',
  custom_fragment => '
  # keep the host
  ProxyPreserveHost On

  # static html, js, images, etc. served from loolwsd
  # loleaflet is the client part of LibreOffice Online
  ProxyPass           /loleaflet https://127.0.0.1:9980/loleaflet retry=0
  ProxyPassReverse    /loleaflet https://127.0.0.1:9980/loleaflet

  # WOPI discovery URL
  ProxyPass           /hosting/discovery https://127.0.0.1:9980/hosting/discovery retry=0
  ProxyPassReverse    /hosting/discovery https://127.0.0.1:9980/hosting/discovery

  # Main websocket
  ProxyPassMatch "/lool/(.*)/ws$" wss://127.0.0.1:9980/lool/$1/ws nocanon

  # Admin Console websocket
  ProxyPass   /lool/adminws wss://127.0.0.1:9980/lool/adminws

  # Download as, Fullscreen presentation and Image upload operations
  ProxyPass           /lool https://127.0.0.1:9980/lool
  ProxyPassReverse    /lool https://127.0.0.1:9980/lool',
  ssl        => true,
  ssl_cert   => '/etc/letsencrypt/live/cloud.perduecloud.com/fullchain.pem',
  ssl_key    => '/etc/letsencrypt/live/cloud.perduecloud.com/privkey.pem',
  additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
}