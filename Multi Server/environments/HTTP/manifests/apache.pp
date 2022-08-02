# Initializes apache
class { 'apache':
  mpm_module    => event,
  default_vhost => false,
}

# Prep vars for mod enabling.
# Merge all mods that need to be enabled into one array,
# Sort them and then remove duplicates.
$concatedmods = concat($apachemods, $codemods, $gitlabmods)
$sortedmods = sort($concatedmods)
$enablemods = unique($sortedmods)

# Enable apache mods
$enablemods.each | String $apachemod | {
  class { "apache::mod::${apachemod}":}
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

# Ensure that a frequented php folder is readable and writeable
file { '/var/lib/php/sessions':
  ensure  => directory,
  owner   => $user,
  group   => $group,
  recurse => true,
}

# Processes each main domain in the $domains variable.
# It then hands the key and the key's value to scope specific variables.
$domains.each | String $maindomain, Array $domainmeta | {

  # Creation of the main domain virtual host
  apache::vhost { $maindomain:
    servername      => $maindomain,
    port            => '80',
    docroot         => "/var/www/${maindomain}",
    docroot_owner   => $user,
    docroot_group   => $group,
    override        => ['all'],
    custom_fragment => "
    <Directory /usr/lib/cgi-bin>
      Require all granted
    </Directory>
    <IfModule mod_fastcgi.c>
      AddHandler php7-fcgi-${maindomain} .php
      Action php7-fcgi-${maindomain} /php7-fcgi-${maindomain} virtual
      Alias /php7-fcgi-${maindomain} /usr/lib/cgi-bin/php7-fcgi-${maindomain}
      FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${maindomain} -socket /run/php/php7.0-fpm.sock -pass-header Authorization
    </IfModule>",
  }

  # Checks if the ssl togge is enabled.
  if $ssltoggle {

    # Creation of the SSL virtual host for the main domain
    apache::vhost { "${maindomain} ssl":
      servername          => $maindomain,
      port                => '443',
      docroot             => "/var/www/${maindomain}",
      docroot_owner       => $user,
      docroot_group       => $group,
      override            => ['all'],
      custom_fragment     => "
      Header always set Strict-Transport-Security \"max-age=15552000; preload\"
      <Directory /usr/lib/cgi-bin>
            Require all granted
      </Directory>
      <IfModule mod_fastcgi.c>
            AddHandler php7-fcgi-${maindomain}-ssl .php
            Action php7-fcgi-${maindomain}-ssl /php7-fcgi-${maindomain}-ssl virtual
            Alias /php7-fcgi-${maindomain}-ssl /usr/lib/cgi-bin/php7-fcgi-${maindomain}-ssl
            FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${maindomain}-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
      </IfModule>",
      ssl                 => true,
      ssl_cert            => "/etc/letsencrypt/live/${ssldomaindir}/fullchain.pem",
      ssl_key             => "/etc/letsencrypt/live/${ssldomaindir}/privkey.pem",
      additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
    }
  }

  # oops through each subdomain and extracts the value to another scope specific variable.
  $domainmeta.each | Array $metadata | {

    # Logic that checks if the vhost should have its own hosting directory. If yes then
    # it assigns the correct value to a variable for use later.
    if $metadata[1] { $metadocroot = "/var/www/${metadata[0]}.${maindomain}" }
    else { $metadocroot = "/var/www/${metadata[2]}" }

    # Creation of the subdomain virtual host
    apache::vhost { "${metadata[0]}.${maindomain}":
      servername      => "${metadata[0]}.${maindomain}",
      port            => '80',
      docroot         => $metadocroot,
      docroot_owner   => $user,
      docroot_group   => $group,
      override        => ['all'],
      custom_fragment => "
      <Directory /usr/lib/cgi-bin>
        Require all granted
      </Directory>
      <IfModule mod_fastcgi.c>
        AddHandler php7-fcgi-${metadata[0]}.${maindomain} .php
        Action php7-fcgi-${metadata[0]}.${maindomain} /php7-fcgi-${metadata[0]}.${maindomain} virtual
        Alias /php7-fcgi-${metadata[0]}.${maindomain} /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${maindomain}
        FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${maindomain} -socket /run/php/php7.0-fpm.sock -pass-header Authorization
      </IfModule>",
    }

    # Checks to see if a SSL vHost should be deployed.
    if $ssltoggle {

      # Creation of the SSL virtual host for the subdomain
      apache::vhost { "${metadata[0]}.${maindomain} ssl":
        servername          => "${metadata[0]}.${maindomain}",
        port                => '443',
        docroot             => $metadocroot,
        docroot_owner       => $user,
        docroot_group       => $group,
        override            => ['all'],
        custom_fragment     => "
        Header always set Strict-Transport-Security \"max-age=15552000; preload\"
        <Directory /usr/lib/cgi-bin>
              Require all granted
        </Directory>
        <IfModule mod_fastcgi.c>
              AddHandler php7-fcgi-${metadata[0]}.${maindomain}-ssl .php
              Action php7-fcgi-${metadata[0]}.${maindomain}-ssl /php7-fcgi-${metadata[0]}.${maindomain}-ssl virtual
              Alias /php7-fcgi-${metadata[0]}.${maindomain}-ssl /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${maindomain}-ssl
              FastCgiExternalServer /usr/lib/cgi-bin/php7-fcgi-${metadata[0]}.${maindomain}-ssl -socket /run/php/php7.0-fpm.sock -pass-header Authorization
        </IfModule>",
        ssl                 => true,
        ssl_cert            => "/etc/letsencrypt/live/${ssldomaindir}/fullchain.pem",
        ssl_key             => "/etc/letsencrypt/live/${ssldomaindir}/privkey.pem",
        additional_includes => '/etc/letsencrypt/options-ssl-apache.conf',
      }
    }
  }
}
