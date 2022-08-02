#
# Auto upgrades for OS
#

# Ensure that package is installed.
package { 'unattended-upgrades': ensure => 'latest' }

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
file_line  {'Unattended_Upgrades APT AutoClean':
  ensure => present,
  path   => '/etc/apt/apt.conf.d/10periodic',
  line   => 'APT::Periodic::AutocleanInterval "7";',
  match  => '^APT::Periodic::AutocleanInterval',
}