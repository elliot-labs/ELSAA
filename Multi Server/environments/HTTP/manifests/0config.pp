#
# -----------------------------------
# Global Settings
# -----------------------------------
#


# System User to run processes as
$user = 'user'


# System Group to run processes as
$group = 'user'


# List of packages to have installed and maintained on the system.
$packages = [ 'unattended-upgrades', 'libapache2-mod-fastcgi', 'php7.0-fpm', 'php7.0', 'python-letsencrypt-apache', 'php7.0-mysql',
'php7.0-zip', 'php7.0-gd', 'php7.0-mbstring', 'php7.0-curl', 'php7.0-xml', 'php7.0-tidy', 'php-apcu', 'php7.0-json',
'php-imagick', 'php7.0-intl', 'php7.0-mcrypt', 'ffmpeg', 'apt-transport-https' ]


#
# -----------------------------------
# Web Server Settings
# -----------------------------------
#


# Hash of domains and subdomains with modifier for subdomain for directory creation/pointing
# Hash key is the domain name with the TLD. The Array in the key contains each subdomain and its configs.
# The subdomain and its options are as follows: ['name of subdomain', bool for creation of hosting folder (true makes one, false does not), 'name of other hosting folder']
# The name of the other hosting folder is the directory in which the subdomain will be hosted from.
$domains = {
'example.com' => [
[ 'www', false, 'example.com' ],
['test', true ],
],
}


# List of apache mods you want to enable.
# You do not have to enable mods for Collabora CODE or GitLabs as they are automatically enabled for you.
# Collabora mod reference: [ 'proxy', 'proxy_wstunnel', 'proxy_http', 'ssl' ]
# GitLabs mod reference: [ 'rewrite', 'ssl', 'proxy', 'proxy_http', 'headers' ]
$apachemods = [ 'ssl', 'rewrite', 'actions', 'proxy_fcgi', 'expires', 'ext_filter', 'fastcgi', 'headers' ]


#
# -----------------------------------
# SSL Settings
# -----------------------------------
#


# SSL toggle, uses letsencrypt.
$ssltoggle = true


# Letsencrypt SSL Certs Dir
$ssldomaindir = 'example.com'


#
# -----------------------------------
# GitLab Settings
# -----------------------------------
#


# Gitlab install toggle.
# REQUIRES the SSL Toggle to be set to true.
$gitlab = true


# Gitlab configuration settings:
# First item in array is the subdomain to which gitlab is installed to.
# Second item is the main domain (with TLD) to which gitlab is installed to.
$gitlabmeta = ['git', 'example.com']


# Apache Mods required for GitLab
# Generally you will not need to touch these.
$gitlabmods = [ 'rewrite', 'ssl', 'proxy', 'proxy_http', 'headers' ]


#
# -----------------------------------
# Collabora CODE Settings
# -----------------------------------
#


# Toggle for Collabora Code Installation
# REQUIRES the SSL toggle to be set to true.
$collabora_code = true


# FQDN (subdomain with domain and TLD) for Collabora CODE installation.
# First array item is the URL of the CODE domain that CODE will run off of.
# Second array item is the URL of the url that is allowed to access the WOPI system.
# The first array item cannot share a domain or subdomain with another system, host, vHost et...
$codedomain = [ 'office.example.com', 'cloud.example.com' ]


# Apache Mods required for Collabora CODE
# Generally you will not need to touch these.
$codemods = [ 'proxy', 'proxy_wstunnel', 'proxy_http', 'ssl' ]


#
# -----------------------------------
# DDClient Settings
# -----------------------------------
#


# Toggle for ddclient installation and configuration.
$ddclient = true


# DDClient configuration
# Only Namecheap is supported right now
# key is the domain name with TLD. no subdomains
# first array item is a string that is the secret key for authentication
# second array item is an array with each DNS A record host that needs to be updated by the client.
$ddclientdata = {
'example.com' => [ 'hsRgjUkrWXPCSnEwJ42GKpw', [ '@', '*' ]],
'example2.xyz' => [ 'hsRgjUkrWXPCSnEwJ42GKpw', ['@', '*' ]],
}


#
# -----------------------------------
# Postprocessing, DO NOT TOUCH THESE!!!
# -----------------------------------
#
