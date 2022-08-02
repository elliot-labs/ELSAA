#
# Service Defs
#

# make sure that the puppet server process runs at boot
service { 'puppetserver':
  ensure => running,
  enable => true,
}

# Autostarts the puppet service
service { 'puppet':
  ensure => running,
  enable => true,
}