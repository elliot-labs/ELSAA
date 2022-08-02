#
# Cloud Storage Defs
#

if $ssltoggle {
  if $collabora_code {

    # Creation of the SSL virtual host for the Collabora CODE online office system.
    apache::vhost { $codedomain[0]:
      servername                => "${codedomain[0]}:443",
      port                      => '443',
      docroot                   => false,
      manage_docroot            => false,
      allow_encoded_slashes     => 'nodecode',
      ssl_proxyengine           => true,
      ssl_proxy_verify          => 'none',
      ssl_proxy_check_peer_cn   => 'off',
      ssl_proxy_check_peer_name => 'off',
      custom_fragment           => '
      # keep the host
      ProxyPreserveHost On
      # static html, js, images, etc. served from loolwsd
      # loleaflet is the client part of LibreOffice Online
      ProxyPass           /loleaflet https://127.0.0.1:9980/loleaflet retry=0
      ProxyPassReverse    /loleaflet https://127.0.0.1:9980/loleaflet
      # WOPI discovery URL
      ProxyPass           /hosting/discovery https://127.0.0.1:9980/hosting/discovery retry=0
      ProxyPassReverse    /hosting/discovery https://127.0.0.1:9980/hosting/discovery
      # Main websocket
      ProxyPassMatch "/lool/(.*)/ws$" wss://127.0.0.1:9980/lool/$1/ws nocanon
      # Admin Console websocket
      ProxyPass   /lool/adminws wss://127.0.0.1:9980/lool/adminws
      # Download as, Fullscreen presentation and Image upload operations
      ProxyPass           /lool https://127.0.0.1:9980/lool
      ProxyPassReverse    /lool https://127.0.0.1:9980/lool',
      ssl                       => true,
      ssl_cert                  => "/etc/letsencrypt/live/${ssldomaindir}/fullchain.pem",
      ssl_key                   => "/etc/letsencrypt/live/${ssldomaindir}/privkey.pem",
      additional_includes       => '/etc/letsencrypt/options-ssl-apache.conf',
    }
  }
}