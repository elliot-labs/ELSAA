if $ddclient {

  # Ensures that the package is installed and updated to the latest version
  package { 'ddclient': ensure => latest, }

  # Configures the service
  -> service {'ddclient':
    ensure => running,
    enable => true,
  }

  # Clears current file and adds header and base configurations.
  file { 'Base DDClient Config':
    ensure  => present,
    path    => '/etc/ddclient.conf',
    content => '# CONFIGURATION FILE MANAGED BY PUPPET!!!
#
# All changes made by users will be destroyed

daemon=3600
use=web, web=dynamicdns.park-your-domain.com/getip

',
  }

  # Loops through all of the specified domains and options to create teh required file.
  $ddclientdata.each | String $ddclientdomain, Array $dddomainmeta | {

    # Add Protocol section to domain configuration
    exec  { "${ddclientdomain} Protocol":
      path    => '/bin',
      command => 'echo "protocol=namecheap" >> /etc/ddclient.conf',
      require => File['Base DDClient Config'],
    }

    # Add SSL section to domain configuration
    -> exec  { "${ddclientdomain} SSL Toggle":
      path    => '/bin',
      command => 'echo "ssl=yes" >> /etc/ddclient.conf',
    }

    # Add Server Config section to domain configuration
    -> exec  { "${ddclientdomain} Server Config":
      path    => '/bin',
      command => 'echo "server=dynamicdns.park-your-domain.com" >> /etc/ddclient.conf',
    }

    # Add Domain Name section to domain configuration
    -> exec  { "${ddclientdomain} Domain Name":
      path    => '/bin',
      command => "echo \"login=${$ddclientdomain}\" >> /etc/ddclient.conf",
    }

    # Add Password section to domain configuration
    -> exec  { "${ddclientdomain} Password":
      path    => '/bin',
      command => "echo \"password=${dddomainmeta[0]}\" >> /etc/ddclient.conf",
    }

    # Add Hosts section to domain configuration
    -> exec  { "${ddclientdomain} Hosts":
      path    => '/bin',
      command => "echo \"join(${dddomainmeta}[1], ',')\" >> /etc/ddclient.conf",
    }

    # Add Whitespace section to domain configuration
    -> exec  { "${ddclientdomain} Whitespace":
      path    => '/bin',
      command => 'echo >> /etc/ddclient.conf',
      notify  => Service['ddclient'],
    }
  }
}