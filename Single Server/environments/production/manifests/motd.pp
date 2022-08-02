#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "An automated server.\n\nThis server is automatically maintained, you better have\na good excuse to be in here...\n\n",
}