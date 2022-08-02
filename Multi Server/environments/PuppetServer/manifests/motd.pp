#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Elliot Labs Puppet Master Server.\n\nThe controle server is automatically maintained, you better have\na good excuse to be in here...\n\n",
}