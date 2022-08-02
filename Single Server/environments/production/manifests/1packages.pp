#
# Package Defs
#


# Prep vars for package installation.
# Merge all packages that need to be enabled into one array,
# Sort the packages and then remove duplicates.

if $httpToggle {
  $pkgs1 = $apachePKGs
} else {
  $pkgs1 = []
}

if $minecraftToggle {
  $pkgs2 = concat($pkgs1, $minecraftPKGs)
} else {
  $pkgs2 = $pkgs1
}

if $syncthingToggle {
  $allPKGs = concat($pkgs2, $syncthingPKGs)
} else {
  $allPKGs = $pkgs2
}

$concatedPKGs = concat($globalPKGs, $allPKGs)
$sortedPKGs = sort($concatedPKGs)
$packages = unique($sortedPKGs)

# Install packages specified inside the 0variables.pp file.
package { $packages: ensure => 'latest' }

# Service declaration, declared to make sure that it is restarted upon config change.
if $httpToggle {
  service { 'php-fpm':
    ensure  => running,
    name    => 'php7.0-fpm',
    enable  => true,
    require => Package[$packages],
  }
}

# Remove OpenSSH server if GitLab is not enabled or if the keep ssh toggle is enabled.
unless $gitLab and $httpToggle or $keepSSH {
  # Purge the open SSH Server software from the system
  package { 'openssh-server': ensure => 'purged' }
}


if $spigotAutoUpdate and $minecraftToggle {
  package { 'screen': ensure => 'latest' }
}

# Auto installs and maintains java runtime environment based upon user selection
if $javaPKG and $minecraftToggle {
  # PreSeeds the installation of Oracle Java 8 JRE to ensure a silent installation
  exec { 'preseed oracle java':
    command => 'echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections',
    path    => [ '/bin', '/usr/bin' ],
  }

  # Installs and maintains the Oracle Java 8 JRE package
  -> package { 'oracle-java8-installer': ensure => 'latest' }

  # Ensures that the OpenJDK package is purged from the system
  package { 'openjdk-8-jre': ensure => 'purged' }
}
elsif $minecraftToggle {
  # Installs and maintains the OpenJDK JRE package
  package { 'openjdk-8-jre': ensure => 'latest' }
}