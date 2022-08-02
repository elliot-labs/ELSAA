#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Elliot Labs Web Server.\n\nThe Web Server is automatically maintained, you better have\na good excuse to be in here...\n\n",
}