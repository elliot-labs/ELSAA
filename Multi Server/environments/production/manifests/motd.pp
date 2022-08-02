#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "An Elliot Labs server.\n\nThis server is unconfigured, authorized personnel\nonly!!!\n\n",
}