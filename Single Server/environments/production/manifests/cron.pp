#
# Cron Def
#

# Automatically runs the puppet apply command
cron { 'PuppetApply':
  ensure  => present,
  command => '/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/',
  user    => 'root',
  hour    => 21,
  minute  => absent,
}

if $sslToggle and $httpToggle {

  # Auto renew SSL certificates. Late - 7PM
  cron { 'LetsEncrypt_Late':
    ensure  => present,
    command => 'letsencrypt renew',
    user    => 'root',
    hour    => 19,
    minute  => absent,
  }

  # Auto renew SSL certificates. Early - 7AM
  cron { 'LetsEncrypt_Early':
    ensure  => present,
    command => 'letsencrypt renew',
    user    => 'root',
    hour    => 7,
    minute  => absent,
  }
}