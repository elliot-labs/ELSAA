if $gitLab and $httpToggle {
  #
  # APT Repository defs
  #

  include apt

  # Add Syncthing Repository to APT
  apt::source { 'GitLab':
    comment  => 'This is the repository for GitLab.',
    location => 'https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/',
    release  => 'trusty',
    repos    => 'main',
    key      => {
      id     => '1A4C919DB987D435939638B914219A96E15E78F4',
      source => 'https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey',
    },
  }

  # Ensure that the system is up to date with the above package list
  -> Class['apt::update']

  #
  # Install GitLab package and ensure that it is the latest version
  #

  # Install package and install updates if available
  -> package { 'gitlab-ce':
      ensure => 'latest',
  }

  # Logic to select the proper protocol to use with GitLab
  if $sslToggle {
    $httpProtocol = 'https'
  }
  else {
    $httpProtocol = 'http'
  }

  # Change GitLab url setting.
  file_line  {'GitLab URL':
  ensure  => present,
  require => Package[ 'gitlab-ce' ],
  path    => '/etc/gitlab/gitlab.rb',
  line    => "external_url \'${httpProtocol}://${gitLabMeta[0]}.${gitLabMeta[1]}\'",
  match   => '^external_url \'',
  notify  => Exec['GitLab Reconfigure']
  }

  exec { 'GitLab Reconfigure':
  path        => '/usr/bin',
  command     => 'gitlab-ctl reconfigure',
  refreshonly => true,
}


  #
  # Apache Defs
  #

  unless $sslToggle {

    # Creation of the virtual host for the GitLab system.
    apache::vhost { "${gitLabMeta[0]}.${gitLabMeta[1]}":
      servername            => "${gitLabMeta[0]}.${gitLabMeta[1]}",
      port                  => '80',
      docroot               => '/opt/gitlab/embedded/service/gitlab-rails/public',
      allow_encoded_slashes => 'nodecode',
      rewrites              => [
        {
          comment      => 'Forward all requests to gitlab-workhorse except existing files like error documents',
          rewrite_cond => ['%{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f [OR]', '%{REQUEST_URI} ^/uploads/.*'],
          rewrite_rule => ['.* http://127.0.0.1:8181%{REQUEST_URI} [P,QSA,NE]'],
        },
      ],
      custom_fragment       => "Header always set Strict-Transport-Security \"max-age=15552000; preload\"
ProxyPreserveHost On

    <Location />
      # New authorization commands for apache 2.4 and up
      # http://httpd.apache.org/docs/2.4/upgrading.html#access
      Require all granted
      #Allow forwarding to gitlab-workhorse
      ProxyPassReverse http://127.0.0.1:8181
      ProxyPassReverse http://${gitLabMeta[0]}.${gitLabMeta[1]}/
    </Location>",
      error_documents       => [
      { 'error_code' => '404', 'document' => '/404.html' },
      { 'error_code' => '422', 'document' => '/422.html' },
      { 'error_code' => '500', 'document' => '/500.html' },
      { 'error_code' => '502', 'document' => '/502.html' },
      { 'error_code' => '503', 'document' => '/503.html' },
      ],
    }

  }
  else {

    # Creation of the HTTP redirect virtual host for the GitLab system.
    apache::vhost { "${gitLabMeta[0]}.${gitLabMeta[1]}":
      servername     => "${gitLabMeta[0]}.${gitLabMeta[1]}",
      port           => '80',
      docroot        => false,
      manage_docroot => false,
      rewrites       => [
        {
          comment      => 'Redirect traffic to HTTPS',
          rewrite_cond => ['%{HTTPS} !=on'],
          rewrite_rule => ['.* https://%{SERVER_NAME}%{REQUEST_URI} [NE,R,L]'],
        },
      ],
    }

    # Creation of the SSL virtual host for the GitLab system.
    apache::vhost { "${gitLabMeta[0]}.${gitLabMeta[1]} ssl":
      servername            => "${gitLabMeta[0]}.${gitLabMeta[1]}",
      port                  => '443',
      docroot               => '/opt/gitlab/embedded/service/gitlab-rails/public',
      allow_encoded_slashes => 'nodecode',
      rewrites              => [
        {
          comment      => 'Forward all requests to gitlab-workhorse except existing files like error documents',
          rewrite_cond => ['%{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f [OR]', '%{REQUEST_URI} ^/uploads/.*'],
          rewrite_rule => ['.* http://127.0.0.1:8181%{REQUEST_URI} [P,QSA,NE]'],
        },
      ],
      custom_fragment       => "Header always set Strict-Transport-Security \"max-age=15552000; preload\"
  RequestHeader set X_FORWARDED_PROTO 'https'
  RequestHeader set X-Forwarded-Ssl on
  ProxyPreserveHost On

    <Location />
      # New authorization commands for apache 2.4 and up
      # http://httpd.apache.org/docs/2.4/upgrading.html#access
      Require all granted
      #Allow forwarding to gitlab-workhorse
      ProxyPassReverse http://127.0.0.1:8181
      ProxyPassReverse http://${gitLabMeta[0]}.${gitLabMeta[1]}/
    </Location>",
      error_documents       => [
      { 'error_code' => '404', 'document' => '/404.html' },
      { 'error_code' => '422', 'document' => '/422.html' },
      { 'error_code' => '500', 'document' => '/500.html' },
      { 'error_code' => '502', 'document' => '/502.html' },
      { 'error_code' => '503', 'document' => '/503.html' },
      ],
      ssl                   => true,
      ssl_cert              => "/etc/letsencrypt/live/${sslDomainDir}/fullchain.pem",
      ssl_key               => "/etc/letsencrypt/live/${sslDomainDir}/privkey.pem",
      additional_includes   => '/etc/letsencrypt/options-ssl-apache.conf',
    }
  }
}