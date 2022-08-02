if $teamSpeakToggle {
  # Makes sure that the Minecraft directory exists and manages permissions.
  file { 'TeamSpeak Dir':
    ensure => directory,
    path   => '/TS/',
    owner  => $user,
    group  => $group,
  }

  # Makes sure that the Spigot hosting directory is present.
  file { 'TeamSpeak Server Dir':
    ensure  => directory,
    path    => '/TS/server/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'TeamSpeak Dir' ],
  }

  # Makes sure that the Spigot build directory is present.
  file { 'TeamSpeak Temp Dir':
    ensure  => directory,
    path    => '/TS/temp/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'TeamSpeak Dir' ],
  }

  # Automatically start the TeamSpeak server on boot and makes sure
  # that the service is running for normal operation.
  service { 'Team Speak Server':
    ensure  => running,
    name    => 'teamspeak',
    enable  => true,
    require => File['TS Service Config'],
  }

  # Creates the systemd service configuration file
  file { 'TS Service Config':
    ensure  => file,
    path    => '/etc/systemd/system/teamspeak.service',
    content => "[Unit]
  Description=TeamSpeak 3, A VOIP server.
  Documentation=https://support.teamspeakusa.com/index.php?/Knowledgebase/List/Index/10/english
  Before=halt.target reboot.target shutdown.target

  [Service]
  Type=forking
  WorkingDirectory=/TS/server/
  User=${user}
  Group=${group}

  # Command to start the server
  ExecStart=/TS/server/ts3server_startscript.sh start

  # Command to stop the server
  ExecStop=/TS/server/ts3server_startscript.sh stop

  # Command to restart the server
  ExecReload=/TS/server/ts3server_startscript.sh restart

  # Identifies the process ID to allow for status checks.
  PIDFile=/TS/server/ts3server.pid

  [Install]
  WantedBy=multi-user.target",
  }
}