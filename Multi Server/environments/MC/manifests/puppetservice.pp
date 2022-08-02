# Auto-starts the puppet service
service { 'puppet':
  ensure => running,
  enable => true,
}
