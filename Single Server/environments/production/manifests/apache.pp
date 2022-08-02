if $httpToggle {

  # Initializes apache
  class { 'apache':
    mpm_module    => event,
    default_vhost => false,
  }

  # Prep vars for mod enabling.
  # Merge all mods that need to be enabled into one array,
  # Sort them and then remove duplicates.
  $concatedMods = concat($apacheMods, $codeMods, $gitLabMods)
  $sortedMods = sort($concatedMods)
  $enableMods = unique($sortedMods)

  # Enable apache mods
  $enableMods.each | String $apacheMod | {
    class { "apache::mod::${apacheMod}":}
  }

  # Automatically sets php-fpm for the correct user.
  file_line  {'PHP-FPM User':
    ensure  => present,
    require => Package[ $packages ],
    notify  => Service['php-fpm'],
    path    => '/etc/php/7.0/fpm/pool.d/www.conf',
    line    => "user = ${user}",
    match   => '^user = ',
  }

  # Automatically sets php-fpm for the correct group.
  file_line  {'PHP-FPM Group':
    ensure  => present,
    require => Package[ $packages ],
    notify  => Service['php-fpm'],
    path    => '/etc/php/7.0/fpm/pool.d/www.conf',
    line    => "group = ${group}",
    match   => '^group = ',
  }

  # Folder permissions for the web folder
  file { '/var/www':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  # Ensure that a frequented php folder is readable and writable
  file { '/var/lib/php/sessions':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  # Processes each main domain in the $domains variable.
  # It then hands the key and the key's value to scope specific variables.
  $domains.each | String $mainDomain, Array $domainMeta | {

    # Creation of the main domain virtual host
    apache::vhost { $mainDomain:
      servername      => $mainDomain,
      port            => '80',
      docroot         => "/var/www/${mainDomain}",
      docroot_owner   => $user,
      docroot_group   => $group,
      override        => ['all'],
      custom_fragment => "
      <Directory /usr/lib/cgi-bin>
        Require all granted
      </Directory>
      <IfModule mod_fastcgi.c>
        AddHandler php7-fcgi-${mainDomain} .php
        Action php7-fcgi-${mainDomain} /php7-fcgi-${mainDomain} virtual
        Alias /php7-fcgi-${mainDomain} /usr/lib/cgi-bin/php7-fcgi-${mainDomain}
        FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${mainDomain} -socket /run/php/php7.0-fpm.sock -pass-header Authorization
      </IfModule>",
    }

    # Checks if the ssl toggle is enabled.
    if $sslToggle {

      # Creation of the SSL virtual host for the main domain
      apache::vhost { "${mainDomain} ssl":
        servername          => $mainDomain,
        port                => '443',
        docroot             => "/var/www/${mainDomain}",
        docroot_owner       => $user,
        docroot_group       => $group,
        override            => ['all'],
        custom_fragment     => "
        Header always set Strict-Transport-Security \"max-age=15552000; preload\"
        <Directory /usr/lib/cgi-bin>
              Require all granted
        </Directory>
        <IfModule mod_fastcgi.c>
              AddHandler php7-fcgi-${mainDomain}-ssl .php
              Action php7-fcgi-${mainDomain}-ssl /php7-fcgi-${mainDomain}-ssl virtual
              Alias /php7-fcgi-${mainDomain}-ssl /usr/lib/cgi-bin/php7-fcgi-${mainDomain}-ssl
              FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${mainDomain}-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
        </IfModule>",
        ssl                 => true,
        ssl_cert            => "/etc/letsencrypt/live/${sslDomainDir}/fullchain.pem",
        ssl_key             => "/etc/letsencrypt/live/${sslDomainDir}/privkey.pem",
        additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
      }
    }

    # oops through each subdomain and extracts the value to another scope specific variable.
    $domainMeta.each | Array $metadata | {

      # Logic that checks if the vhost should have its own hosting directory. If yes then
      # it assigns the correct value to a variable for use later.
      if $metadata[1] { $metaDocRoot = "/var/www/${metadata[0]}.${mainDomain}" }
      else { $metaDocRoot = "/var/www/${metadata[2]}" }

      # Creation of the subdomain virtual host
      apache::vhost { "${metadata[0]}.${mainDomain}":
        servername      => "${metadata[0]}.${mainDomain}",
        port            => '80',
        docroot         => $metaDocRoot,
        docroot_owner   => $user,
        docroot_group   => $group,
        override        => ['all'],
        custom_fragment => "
        <Directory /usr/lib/cgi-bin>
          Require all granted
        </Directory>
        <IfModule mod_fastcgi.c>
          AddHandler php7-fcgi-${metadata[0]}.${mainDomain} .php
          Action php7-fcgi-${metadata[0]}.${mainDomain} /php7-fcgi-${metadata[0]}.${mainDomain} virtual
          Alias /php7-fcgi-${metadata[0]}.${mainDomain} /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${mainDomain}
          FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${mainDomain} -socket /run/php/php7.0-fpm.sock -pass-header Authorization
        </IfModule>",
      }

      # Checks to see if a SSL vHost should be deployed.
      if $sslToggle {

        # Creation of the SSL virtual host for the subdomain
        apache::vhost { "${metadata[0]}.${mainDomain} ssl":
          servername          => "${metadata[0]}.${mainDomain}",
          port                => '443',
          docroot             => $metaDocRoot,
          docroot_owner       => $user,
          docroot_group       => $group,
          override            => ['all'],
          custom_fragment     => "
          Header always set Strict-Transport-Security \"max-age=15552000; preload\"
          <Directory /usr/lib/cgi-bin>
                Require all granted
          </Directory>
          <IfModule mod_fastcgi.c>
                AddHandler php7-fcgi-${metadata[0]}.${mainDomain}-ssl .php
                Action php7-fcgi-${metadata[0]}.${mainDomain}-ssl /php7-fcgi-${metadata[0]}.${mainDomain}-ssl virtual
                Alias /php7-fcgi-${metadata[0]}.${mainDomain}-ssl /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${mainDomain}-ssl
                FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${mainDomain}-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
          </IfModule>",
          ssl                 => true,
          ssl_cert            => "/etc/letsencrypt/live/${sslDomainDir}/fullchain.pem",
          ssl_key             => "/etc/letsencrypt/live/${sslDomainDir}/privkey.pem",
          additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
        }
      }
    }
  }
}