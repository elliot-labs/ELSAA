#
# Cron Def
#

if $ssltoggle {

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