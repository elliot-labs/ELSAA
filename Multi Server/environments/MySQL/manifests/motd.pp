#
# Login message defs
#

# Creates logon message
class { 'motd':
  content => "Elliot Labs SQL Server.\n\nThe SQL Server is automatically maintained, you better have\na good excuse to be in here...\n\n",
}