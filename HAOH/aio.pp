# Required Modules:
#
# puppetlabs-mysql
# puppetlabs-apache
# puppetlabs-motd
# puppetlabs-stdlib
#
#


#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "History at our house's web server.\n\nWordPress is automatically maintained, you better have\na good excuse to be in here...\n\n",
}


#
# install packages
#

# Lists the packages that need to be installed.
$packages = [ 'unattended-upgrades', 'libapache2-mod-fastcgi', 'php7.0-fpm', 'php7.0', 'python-letsencrypt-apache',
'php7.0-mysql', 'php7.0-zip', 'php7.0-gd', 'php7.0-mbstring', 'php7.0-curl', 'php7.0-xml', 'php7.0-tidy', 'php-apcu' ]

# Takes the previous list, installs and or updates the packages to the latest version(s).
package { $packages: ensure => 'latest' }

file { 'pagespeed_deb':
  path => '/tmp/mod-pagespeed-stable_current_amd64.deb',
  ensure => present,
  source => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb',
} ->

package { "mod_pagespeed":
 provider => dpkg,
 ensure   => latest,
 source   => "/tmp/mod-pagespeed-stable_current_amd64.deb"
}


#
# MySQL Defs
#

# MySQL server setup
class { '::mysql::server':
  root_password           => '**REMOVED**',
  remove_default_accounts => true,
}

# HAOH DB creation
mysql::db { 'haoh_wp':
  user     => '**REMOVED**',
  password => '**REMOVED**',
  host     => 'localhost',
  charset  => 'utf8mb4',
  collate  => 'utf8mb4_general_ci',
}

# PowellHistory DB creation
mysql::db { 'powellhistory_wp':
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
  command => '/usr/bin/letsencrypt renew',
  user    => 'root',
  hour    => 19,
  minute  => absent,
}

# Auto renew SSL certificates. Early - 7AM
cron { 'LetsEncrypt_Early':
  ensure  => present,
  command => '/usr/bin/letsencrypt renew',
  user    => 'root',
  hour    => 7,
  minute  => absent,
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

# Breaks up updates into smaller segments to allow for the ability to reboot whenever.
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
# Apache Defs
#

# Initializes apache
class { 'apache':
  mpm_module    => event,
  default_vhost => false,
  user          => **REMOVED**,
  group         => **REMOVED**,
}

# Enable apache mods
class { 'apache::mod::rewrite':}
class { 'apache::mod::actions':}
class { 'apache::mod::proxy':}
class { 'apache::mod::proxy_http':}
class { 'apache::mod::proxy_fcgi':}
class { 'apache::mod::ssl': }
class { 'apache::mod::pagespeed':}
class { 'apache::mod::fastcgi': }

# Folder permissions for WordPress
file { '/var/www' :
    ensure  => directory,
    owner   => '**REMOVED**',
    group   => '**REMOVED**',
    require => [ User['**REMOVED**'], Group['**REMOVED**'], ],
    recurse => true,
}

# The WordPress virtual host
apache::vhost { 'historyatourhouse.com':
  servername      => 'historyatourhouse.com',
  serveraliases   => ['*.historyatourhouse.com'],
  port            => '80',
  docroot         => '/var/www/HAOH/',
  docroot_owner   => '**REMOVED**',
  docroot_group   => '**REMOVED**',
  override        => ['all'],
  custom_fragment => '
  <Directory /usr/lib/cgi-bin>
    Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
    AddHandler php7-fcgi .php
    Action php7-fcgi /php7-fcgi virtual
    Alias /php7-fcgi /usr/lib/cgi-bin/php7-fcgi
    FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
}

# The SSL virtual host for WordPress
apache::vhost { 'historyatourhouse.com_ssl':
  servername      => 'historyatourhouse.com',
  serveraliases   => ['*.historyatourhouse.com'],
  port            => '443',
  docroot         => '/var/www/HAOH/',
  docroot_owner   => '**REMOVED**',
  docroot_group   => '**REMOVED**',
  override        => ['all'],
  custom_fragment => '
  <Directory /usr/lib/cgi-bin>
        Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
        AddHandler php7-fcgi-ssl .php
        Action php7-fcgi-ssl /php7-fcgi-ssl virtual
        Alias /php7-fcgi-ssl /usr/lib/cgi-bin/php7-fcgi-ssl
        FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
  ssl        => true,
  ssl_cert   => '/etc/letsencrypt/live/historyatourhouse.com-0001/fullchain.pem',
  ssl_key    => '/etc/letsencrypt/live/historyatourhouse.com-0001/privkey.pem',
  additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
}

# The PowellHistory virtual host
apache::vhost { 'powellhistory.com':
  servername      => 'powellhistory.com',
  serveraliases   => ['*.powellhistory.com'],
  port            => '80',
  docroot         => '/var/www/PowellHistory/',
  docroot_owner   => '**REMOVED**',
  docroot_group   => '**REMOVED**',
  override        => ['all'],
  custom_fragment => '
  <Directory /usr/lib/cgi-bin>
    Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
    AddHandler php7-fcgi-ph .php
    Action php7-fcgi-ph /php7-fcgi-ph virtual
    Alias /php7-fcgi-ph /usr/lib/cgi-bin/php7-fcgi-ph
    FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-ph -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
}

# The SSL virtual host for WordPress
apache::vhost { 'powellhistory.com_ssl':
  servername      => 'powellhistory.com',
  serveraliases   => ['*.powellhistory.com'],
  port            => '443',
  docroot         => '/var/www/PowellHistory/',
  docroot_owner   => '**REMOVED**',
  docroot_group   => '**REMOVED**',
  override        => ['all'],
  custom_fragment => '
  <Directory /usr/lib/cgi-bin>
        Require all granted
  </Directory>
  <IfModule mod_fastcgi.c>
        AddHandler php7-fcgi-ph-ssl .php
        Action php7-fcgi-ph-ssl /php7-fcgi-ph-ssl virtual
        Alias /php7-fcgi-ph-ssl /usr/lib/cgi-bin/php7-fcgi-ph-ssl
        FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-ph-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
  </IfModule>',
  ssl        => true,
  ssl_cert   => '/etc/letsencrypt/live/powellhistory.com-0001/fullchain.pem',
  ssl_key    => '/etc/letsencrypt/live/powellhistory.com-0001/privkey.pem',
  additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
}