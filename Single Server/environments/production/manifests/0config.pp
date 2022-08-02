#
# -----------------------------------
# Component Toggles
# -----------------------------------
#


# Toggles the firewall.
$firewallToggle = false


# Toggles the installation of web server components.
$httpToggle = false


#Toggles the installation and configuration of ddClient components.
$ddClientToggle = false


# Toggles the installation of MySQL server components.
$mysqlToggle = false


# Toggles the installation of Minecraft/Spigot server components.
$minecraftToggle = false


# Toggles the installation of TeamSpeak server components.
$teamSpeakToggle = false


# Toggles the installation of Syncthing.
$syncthingToggle = false


#
# -----------------------------------
# Global Settings
# -----------------------------------
#


# List of packages to have installed and maintained on the system.
$globalPKGs = []


# Java toggle:
# Entering "true" installs and maintains the Oracle Java 8 Runtime package and dependencies.
# Specifying "false" with Minecraft enabled,
# installs and maintains the OpenJDK Java 8 Runtime and dependencies.
$javaPKG = false


# System User to run processes as
$user = 'SomeUserHere'


# System Group to run processes as
$group = 'SomeGroupHere'


# Toggles puppet report generation. False = off, True = on
$puppetReporting = false


# Keeps SSH installed on the system. By default the package system automatically removes the SSH
# package for security reasons.
$keepSSH = false


#
# -----------------------------------
# HTTP Settings
# -----------------------------------
#


# Hash of domains and subdomains with modifier for subdomain for directory creation/pointing
# Hash key is the domain name with the TLD. The Array in the key contains each subdomain and its configs.
# The subdomain and its options are as follows:
# ['name of subdomain', bool for creation of hosting folder (true makes one, false does not), 'name of other hosting folder']
# The name of the other hosting folder is the directory in which the subdomain will be hosted from.
$domains = {
'example.com' => [
[ 'www', false, 'example.com' ],
['cloud', true],
],
'contoso.xyz' => [
[ 'www', false, 'contoso.xyz' ],
]}


# SSL toggle, uses Let's Encrypt.
$sslToggle = true


# Let's Encrypt SSL Certs Dir
$sslDomainDir = 'example.com'


# List of packages related to Apache to have installed and maintained on the system.
$apachePKGs = [ 'libapache2-mod-fastcgi', 'php7.0-fpm', 'php7.0', 'python-letsencrypt-apache', 'php7.0-mysql',
'php7.0-zip', 'php7.0-gd', 'php7.0-mbstring', 'php7.0-curl', 'php7.0-xml', 'php7.0-tidy', 'php-apcu', 'php7.0-json',
'php-imagick', 'php7.0-intl', 'php7.0-mcrypt', 'ffmpeg' ]


# List of apache mods you want to enable.
# You do not have to enable mods for Collabora CODE or GitLabs as they are automatically enabled for you.
$apacheMods = [ 'ssl', 'rewrite', 'actions', 'proxy_fcgi', 'expires', 'ext_filter', 'fastcgi', 'headers' ]


# Toggle for Collabora Code Installation
# REQUIRES the SSL toggle to be set to true.
$collaboraCode = true


# FQDN (subdomain with domain and TLD) for Collabora CODE installation.
# First array item is the URL of the CODE domain that CODE will run off of.
# Second array item is the URL of the url that is allowed to access the WOPI system.
# The first array item cannot share a domain or subdomain with another system, host, vHost etc...
$codeDomain = [ 'office.example.com', 'cloud.example.com' ]


# GitLab install toggle.
# REQUIRES the SSL Toggle to be set to true.
$gitLab = true


# GitLab configuration settings:
# First item in array is the subdomain to which GitLab is installed to.
# Second item is the main domain (with TLD) to which GitLab is installed to.
$gitLabMeta = ['git', 'example.com']


# Apache Mods required for Collabora CODE
# Generally you will not need to touch these.
$codeMods = [ 'proxy', 'proxy_wstunnel', 'proxy_http', 'ssl' ]


# Apache Mods required for GitLab
# Generally you will not need to touch these.
$gitLabMods = [ 'rewrite', 'ssl', 'proxy', 'proxy_http', 'headers' ]


#
# -----------------------------------
# ddClient Settings
# -----------------------------------
#


# DDClient configuration
# Only NameCheap is supported right now
# key is the domain name with TLD. no subdomains
# first array item is a string that is the secret key for authentication
# second array item is an array with each DNS A record host that needs to be updated by the client.
$ddClientData = {
'example.com' => [ 'SecretKeyHere', [ '@', '*' ]],
'contoso.xyz' => [ 'SecretKeyHere', ['@', '*' ]],
}


#
# -----------------------------------
# MySQL Settings
# -----------------------------------
#


# The hash key is the section name and sub hashes are item and value configs for that specified item in the hash section.
$mysqlOptions = {
  'client' => {
  'socket'         => '/run/mysqld/mysqld.sock',
  },
  'mysqld' => {
    'bind-address' => '0.0.0.0',
  },
}


# Root password for MySQL. Root is only log in-able from localhost.
$mysqlRootPWD = 'SomeRandomPasswordHere'


# List of databases to create and with the corresponding configuration options.
# Hash key is the name of the database (string).
# First array item is the name of the corresponding DB user.
# Second array item is the password for the corresponding DB user.
# The third array item is the host name that is allowed to access the database.
$databases = {
'databasename'  => ['username', 'SomeRandomPasswordHere', '192.168.0.1' ],
'databasename2' => ['other_user', 'SomeRandomPasswordHere', '192.168.0.2' ],
}


# <TODO>
# Enabling this setting will enforce the host settings on the database.
# Keeping this disabled will allow hosts settings to stack:
# If the settings are changed the old settings will be retained in addition to the new ones.


$dbPermissionsPurge = false
# </TODO>


#
# -----------------------------------
# Minecraft/Spigot Settings
# -----------------------------------
#


# List of packages related to Minecraft to have installed and maintained on the system.
$minecraftPKGs = ['git']


# Spigot Auto Update:
# Automatically updates the spigot server if set to true.
$spigotAutoUpdate = true


# Spigot Version:
# BuildTools pulls this variable to build the version of spigot that you select.
# https://www.spigotmc.org/wiki/buildtools/#versions
$spigotVersion = '1.12.2'


# Minimum RAM for the Spigot server.
# M = Megabytes, G = Gigabytes
$spigotMinRAM = '256M'


# Maximum RAM for the Spigot server.
# M = Megabytes, G = Gigabytes
$spigotMaxRAM = '5G'


# Toggle the inclusion of a 5, 4, 3, 2, 1 countdown on Minecraft server stop.
$countDownToggle = true


# Sets the delay time between first server stop warning and the second server stop warning.
$alertTime1 = '30'


# Sets the wording for the initial alert that is displayed to players before the server stops.
$serverStoppingAlert1 = "Server is stopping in ${alertTime1} seconds, please be ready to disconnect."


# Sets the delay time between first server stop warning and the second server stop warning.
# After this delay, the server will count down every second from 5 seconds till shutdown.
$alertTime2 = '10'


# Sets the wording for the initial alert that is displayed to players before the server stops.
# After this warning is displayed, the server will count down every second from 5 seconds till shutdown.
$serverStoppingAlert2 = "Server is stopping in ${alertTime2} seconds, please disconnect ASAP!"


#
# -----------------------------------
# TeamSpeak Settings
# -----------------------------------
#


# Defines the version of TeamSpeak server to download.
# the current version can be found here:
# https://www.teamspeak.com/downloads.html#server
$tsServerVersion = '3.0.13.8'


# Defines the processor architecture for the TeamSpeak server.
# false sets the arch type to 32bit.
# true sets the arch type to 64bit.
$tsCPUArchType = true


# Defines the operating system type that TS is being deployed to.
# Valid options are:
# 'Windows', 'MAC', 'Linux' and 'FreeBSD'
$tsOSType = 'Linux'


#
# -----------------------------------
# Syncthing Settings
# -----------------------------------
#


# If set to true then syncthing will start automatically on boot.
$syncthingAutoRun = true


# Sets the address that the GUI will be accessible from.
# 0.0.0.0 means that it will be available from all addresses.
$syncthingGUIAddr = '127.0.0.1'


# Sets the port number that the GUI will be accessible from.
# The default is '8384'.
$syncthingGUIPort = '8384'


# Defines the required packages for Syncthing.
$syncthingPKGs = ['syncthing']


#
# -----------------------------------
# Firewall Settings
# -----------------------------------
#

# Accept = open firewall port
# Drop = ignores traffic on port, does not send response
# Reject = does not accept traffic and notifies client.

# Accepts traffic on the specified ports.
# The index of the dictionary is the name of the port to be opened, this is a friendly name for admins.
# The first parameter in the array is the port.
# The second is the protocol.
# The third is the importance value of the Rule, 0 being the highest and 999 being the lowest
# The fourth is the name of the action that should be taken on the specified rule.
# Importance values that can be used are 003-997 (inclusive). The lower the number the higher the rule is in the firewall chain.
$ports = { 'Friendly Name' => ['005', '80', 'tcp', 'accept'] }
