#
# -----------------------------------
# Global Settings
# -----------------------------------
#


# Installs and maintains the specified package(s).
$packages = ['git']


# Java toggle:
# Entering "true" installs and maintains the Oracle Java 8 Runtime package and dependencies.
# Specifying "false" installs and maintains the OpenJDK Java 8 Runtime and dependencies.
$javaPKG = true


# System User to run processes as.
$user = 'elliot'


# System Group to run processes as.
$group = 'elliot'


#
# -----------------------------------
# Minecraft/Spigot Settings
# -----------------------------------
#


# Spigot Auto Update:
# Automatically updates the spigot server if set to true.
$spigotAutoUpdate = true


# Spigot Version:
# BuildTools pulls this variable to build the version of spigot that you select.
# https://www.spigotmc.org/wiki/buildtools/#versions
$spigotVersion = '1.12.2'


# Minimum RAM for the Spigot server.
$spigotMinRAM = '256M'


# Maximum RAM for the Spigot server.
$spigotMaxRAM = '5G'


# Toggle the inclusion of a 5, 4, 3, 2, 1 countdown on Minecraft server stop.
$countdownToggle = true


# Sets the delay time between first server stop warning second server stop warning.
$alertTime1 = '30'


# Specify the chat command of your choice to broad cast your messages to the server.
# "broadcast" is specifically with the 'essentials' series fo plugins and is not compatible by default.
# "say" is a command that is compatible with vanilla minecraft but is not as fancy as proprietary commands.
# You can use whatever command you want, just know that this option is the very first text that is introduced to the server.
$mcChatCommand = 'broadcast'


# Sets the wording for the initial alert that is displayed to players before the server stops.
$serverStoppingAlert1 = "Server is stopping in ${alertTime1} seconds, please be ready to disconnect."


# Sets the delay time between first server stop warning second server stop warning.
# After this delay, the server will count down every second from 5 seconds till shutdown.
$alertTime2 = '10'


# Sets the wording for the initial alert that is displayed to players before the server stops.
# After this warning is displayed, the server will count down every second from 5 seconds till shutdown.
$serverStoppingAlert2 = "Server is stopping in ${alertTime2} seconds, please disconnect ASAP!"


# Set the base directory for the Minecraft server installation.
# The default setting is on the root of the hard drive in the /MC folder.
$mcBaseDir = '/MC'


# Sets the server directory. This is the directory that the live server will run out of.
# This directory will sit on top of whatever the base dir is set to, E.G. ${mcBaseDir}${mcServerDir}/, E.G.2 /MC/Server/
$mcServerDir = 'Server'


# Sets the Build Tools directory. This directory will be the directory that Build Tools is downloaded to and run in.
# This directory will sit on top of whatever the base dir is set to, E.G. ${mcBaseDir}${mcBuildToolsDir}/, E.G.2 /MC/BuildTools/
$mcBuildToolsDir = 'BuildTools'


# Sets the server backup directory. This directory will be used to house backups.
# You can set this directory option to any fully qualified path.
$mcBackupsDir = "${mcBaseDir}/Backups"


# Sets the Build Tools directory. This directory will be the directory that Build Tools is downloaded to and run in.
# This directory will sit on top of whatever the base dir is set to, E.G. ${mcBaseDir}${mcTempDir}/, E.G.2 /MC/Temp/
$mcTempDir = 'Temp'


#
# -----------------------------------
# Postprocessing, DO NOT TOUCH THESE!!!
# -----------------------------------
#


# Automatically define the directories in a single array.
# This is useful for a single file resource that automatically creates all of the directories in one definition.
$mcDirs = ["${mcBaseDir}", "${mcBaseDir}/${mcServerDir}", "${mcBaseDir}/${mcBuildToolsDir}", "${mcBackupsDir}", "${mcBaseDir}/${mcTempDir}"]
