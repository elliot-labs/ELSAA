#
# Package Defs
#

# Install packages specified inside the config file.
package { $packages: ensure => 'latest' }

if $spigotAutoUpdate {
  package { 'screen': ensure => 'latest' }
}

# Auto installs and maintains java runtime environment based upon user selection
if $javaPKG {

  # Pre-seeds the installation of Oracle Java 8 JRE to ensure a silent installation
  exec { 'Preseed Oracle Java':
    command => 'echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections',
    path    => [ '/bin', '/usr/bin' ],
    creates => '/MC/PreseedJava.txt',
  }

  # Create a file to limit execution of the preseed oracle java command. The command only needs to run once.
  file { 'Preseed Validation':
    ensure  => file,
    path    => '/MC/PreseedJava.txt',
    owner   => $user,
    group   => $group,
    content => 'Java package is preseeded',
    require => [
      File[$mcDirs],
      Exec['Preseed Oracle Java'],
    ],
  }

  # Installs and maintains the Oracle Java 8 JRE package
  package { 'oracle-java8-installer':
    ensure  => latest,
    require => [
      Apt::Ppa['ppa:webupd8team/java'],
      Exec['Preseed Oracle Java']
    ],
  }

  # Ensures that the OpenJDK package is purged from the system
  package { 'openjdk-8-jre': ensure => purged }

} else {

  # Installs and maintains teh OpenJDK JRE package
  package { 'openjdk-8-jre': ensure => latest }

}
