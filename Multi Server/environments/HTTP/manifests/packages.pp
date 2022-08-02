#
# Package Defs
#


# Install packages specified inside the 0variabes.pp file.
package { $packages: ensure => 'latest' }

# Service declaration, declared to make sure that it is restarted upon config change.
-> service { 'php-fpm':
  ensure => running,
  name   => 'php7.0-fpm',
  enable => true,
}

# Remove OpenSSH server if GitLab is not enabled.
unless $gitlab {

  # Purge the open SSH Server software from the system
  package { 'openssh-server': ensure => purged, }

}
