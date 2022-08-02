# Defines the version of TeamSpeak server to download.
# the current version can be found here:
# https://www.teamspeak.com/downloads.html#server
$tsserverversion = '3.0.13.6'

# Defines the processor architecture for the teamspeak server.
# false sets the arch type to 32bit.
# true sets the arch type to 64bit.
$tscpuarchtype = true

# Defines teh operating system type that TS is being deployed to.
# Valid options are:
# 'Windows', 'MAC', 'Linux' and 'FreeBSD'
$tsostype = 'Linux'

# System User to run processes as
$user = 'elliot'

# System Group to run processes as
$group = 'elliot'