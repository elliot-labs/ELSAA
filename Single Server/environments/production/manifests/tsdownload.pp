if $teamSpeakToggle {
  # logic that builds the download url based upon the users selection in the
  # variables file.
  $baseURL = "http://dl.4players.de/ts/releases/${tsServerVersion}/"

  case $tsOSType {

    'Windows':    {
      unless $tsCPUArchType {
        $downloadFile = "teamspeak3-server_win32-${tsServerVersion}.zip"
      }
      if $tsCPUArchType {
        $downloadFile = "teamspeak3-server_win64-${tsServerVersion}.zip"
      }
    }
    'MAC': { $downloadFile = "teamspeak3-server_mac-${tsServerVersion}.zip" }
    'Linux': {
      unless $tsCPUArchType {
        $downloadFile = "teamspeak3-server_linux_x86-${tsServerVersion}.tar.bz2"
      }
      if $tsCPUArchType {
        $downloadFile = "teamspeak3-server_linux_amd64-${tsServerVersion}.tar.bz2"
      }
    }
    'FreeBSD': {
      unless $tsCPUArchType {
        $downloadFile = "teamspeak3-server_freebsd_x86-${tsServerVersion}.tar.bz2"
      }
      if $tsCPUArchType {
        $downloadFile = "teamspeak3-server_freebsd_amd64-${tsServerVersion}.tar.bz2"
      }
    }
    default: {fail('No matching operating system selected!')}
  }

  $downloadURL = "${baseURL}${downloadFile}"

  exec { 'Download Archive':
    command => "/usr/bin/wget ${downloadURL} -O /TS/temp/${downloadFile}",
    cwd     => '/TS/temp/',
    creates => "/TS/temp/${downloadFile}",
    user    => $user,
    notify  => Exec['Extract Archive'],
    require => File['TeamSpeak Temp Dir'],
  }

  exec { 'Extract Archive':
    command     => "/bin/tar -xjf ${downloadFile} --directory /TS/server/ --overwrite --strip-components=1",
    cwd         => '/TS/temp',
    refreshonly => true,
    user        => $user,
    require     => File[ 'TeamSpeak Server Dir' ],
  }
}