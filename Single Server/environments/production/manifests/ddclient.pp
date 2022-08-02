if $ddClientToggle {

  # Ensures that the package is installed and updated to the latest version
  package { 'ddclient': ensure => latest, }

  # Configures the service
  -> service { 'ddclient':
    ensure => running,
    enable => true,
  }

  # Clears current file and adds header and base configurations.

  concat { '/etc/ddclient.conf':
      ensure => present,
  }

  concat::fragment { 'header':
    target  => '/etc/ddclient.conf',
    content => '# CONFIGURATION FILE MANAGED BY PUPPET!!!
#
# All changes made by users will be destroyed

daemon=3600
use=web, web=dynamicdns.park-your-domain.com/getip

',
    order   => '01',
  }

  # Loops through all of the specified domains and options to create the required file.
  $ddClientData.each | String $ddClientDomain, Array $ddDomainMeta | {

    concat::fragment { "body_for_${ddClientDomain}":
      target  => '/etc/ddclient.conf',
      content => "protocol=namecheap
ssl=yes
server=dynamicdns.park-your-domain.com
login=${ddClientDomain}
password=${ddDomainMeta[0]}
${join($ddDomainMeta[1], ',')}

",
      order   => '02',
    }
  }
}