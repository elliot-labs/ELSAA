# Required Modules:
#
# puppetlabs-motd
# puppetlabs-stdlib
# puppetlabs-tftp
# puppetlabs-dhcp
# puppetlabs-xinetd
#
#


#
# install packages
#

# Lists the packages that need to be installed.
$packages = [ 'unattended-upgrades', 'samba' ]

# Takes the previous list, installs and or updates the packages to the latest version(s).
package { $packages: ensure => 'latest' }


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
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Elliot Labs Automated Deployment System - ELADS.\n\nELADS is automatically maintained, you better have\na good excuse to be in here...\n\n",
}


#
# TFTP-HPA Defs
#

# Configure TFTP
class { 'tftp':
  directory => '/var/lib/tftpboot',
  options => '--listen --secure',
  inetd: false,
}


#
# xinetd Defs
#

class { 'xinetd':}

xinetd::service { 'tftp':
  server      => '/usr/sbin/in.tftpd',
  server_args => '-s /var/lib/tftp/',
  socket_type => 'dgram',
  protocol    => 'udp',
}


#
# DHCP Server Defs
#

# Configure the DHCP Service
class { 'dhcp':
  service_ensure => running,
  dnsdomain      => [ 'elads.elliot-labs.local' ],
  nameservers  => [ '8.8.8.8', '8.8.4.4', '8.26.56.26', '8.20.247.20' ],
  ntpservers   => ['us.pool.ntp.org'],
  pxeserver    => '192.168.25.1',
  pxefilename  => 'pxelinux.0',
}

# Configure the DHCP address pool
dhcp::pool{ 'ELADS DHCP Settings':
  network => '192.168.25.0',
  mask    => '255.255.0.0',
  range   => ['192.168.25.2', '192.168.25.254'],
  gateway => '192.168.0.1',
}


#
# Cron Def
#

# Autorun Puppet at 9pm every day.
cron { 'PuppetApply':
  ensure  => present,
  command => '/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/aio.pp',
  user    => 'root',
  hour    => 21,
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

# The WordPress virtual host
apache::vhost { 'Deployment HTTP':
  servername      => '192.168.25.1',
  port            => '80',
  docroot         => '/var/www/html',
  docroot_owner   => 'www-data',
  docroot_group   => 'www-data',
  override        => ['all'],
}