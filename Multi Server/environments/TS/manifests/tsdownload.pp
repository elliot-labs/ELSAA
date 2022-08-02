# logic that builds the download url based upon the users selection in the
# variables file.
$baseurl = "http://dl.4players.de/ts/releases/${tsserverversion}/"

case $tsostype {

  'Windows':    {
    unless $tscpuarchtype {
      $downloadfile = "teamspeak3-server_win32-${tsserverversion}.zip"
    }
    if $tscpuarchtype {
      $downloadfile = "teamspeak3-server_win64-${tsserverversion}.zip"
    }
  }
  'MAC': { $downloadfile = "teamspeak3-server_mac-${tsserverversion}.zip" }
  'Linux': {
    unless $tscpuarchtype {
      $downloadfile = "teamspeak3-server_linux_x86-${tsserverversion}.tar.bz2"
    }
    if $tscpuarchtype {
      $downloadfile = "teamspeak3-server_linux_amd64-${tsserverversion}.tar.bz2"
    }
  }
  'FreeBSD': {
    unless $tscpuarchtype {
      $downloadfile = "teamspeak3-server_freebsd_x86-${tsserverversion}.tar.bz2"
    }
    if $tscpuarchtype {
      $downloadfile = "teamspeak3-server_freebsd_amd64-${tsserverversion}.tar.bz2"
    }
  }
  default: {fail('No matching operating system selected!')}
}

$downloadurl = "${baseurl}${downloadfile}"

exec { 'Download Archive':
  command => "/usr/bin/wget ${downloadurl} -O /TS/temp/${downloadfile}",
  cwd     => '/TS/temp/',
  creates => "/TS/temp/${downloadfile}",
  user    => $user,
  notify  => Exec['Extract Archive'],
  require => File['TeamSpeak Temp Dir'],
}

exec { 'Extract Archive':
  command     => "/bin/tar -xjf ${downloadfile} --directory /TS/server/ --overwrite --strip-components=1",
  cwd         => '/TS/temp',
  refreshonly => true,
  user        => $user,
  require     => File[ 'TeamSpeak Server Dir' ],
}