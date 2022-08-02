# If puppet reporting is set to true in the configuration file then
# make sure that the reporting is not disabled.
if $puppetReporting {
  file_line { 'Puppet Report':
    ensure            => absent,
    path              => '/etc/puppetlabs/puppet/puppet.conf',
    line              => 'reports = none',
    match             => '^reports = ',
    match_for_absence => true,
  }
}
# if reporting is disabled then make sure that reporting is disabled.
elsif !$puppetReporting {
  file_line { 'Puppet Report':
    ensure => present,
    path   => '/etc/puppetlabs/puppet/puppet.conf',
    match  => '^reports = ',
    line   => 'reports = none',
  }
}