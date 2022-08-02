#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Elliot Labs TeamSpeak Server.\n\nThe ELTS is automatically maintained, you better have\na good excuse to be in here...\n\n",
}