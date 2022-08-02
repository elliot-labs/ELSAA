#
# Service Defs
#

# Autostarts the puppet service
service { 'puppet':
  ensure => running,
  enable => true,
}