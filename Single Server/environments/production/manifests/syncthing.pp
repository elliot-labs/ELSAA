# Only process if the syncthing component is set to install (true)
if $syncthingToggle {

  # Creates the systemd service entry for auto start
  file { 'Syncthing Auto Start Service':
    ensure  => file,
    path    => '/etc/systemd/system/syncthing@.service',
    owner   => 'root',
    group   => 'root',
    content => '[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target
Wants=syncthing-inotify@.service

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target',
  }

  # Creates the systemd resume script for making Syncthing more responsive when
  # coming out of sleep.
  file { 'Syncthing Suspend Support':
    ensure  => file,
    path    => '/etc/systemd/system/syncthing-resume.service',
    owner   => 'root',
    group   => 'root',
    content => '[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target
Wants=syncthing-inotify@.service

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target',
  }

  # Makes sure that the syncthing service is runing.
  service { 'Syncthing':
    ensure    => 'running',
    name      => "syncthing@${user}.service",
    enable    => true,
    require   => File['Syncthing Auto Start Service'],
    subscribe => File_Line['GUI Address and Port'],
  }

  # Makes sure that graceful resume is enabled.
  service { 'Syncthing Resume Support':
    name    => 'syncthing-resume.service',
    enable  => true,
    require => File['Syncthing Suspend Support'],
  }

  # Syncthing GUI Listening Address and Port Configuration
  file_line {'GUI Address and Port':
    ensure => present,
    line   => "        <address>${syncthingGUIAddr}:${syncthingGUIPort}</address>",
    after  => '<gui\s[a-z="\s]*>',
    path   => "/home/${user}/.config/syncthing/config.xml",
    match  => '(<address>[0-2]?[0-9]?[0-9]\.[0-2]?[0-9]?[0-9]\.[0-9]?[0-9]?[0-9]\.[0-9]?[0-9]?[0-9]:[0-6]?[0-9]?[0-9]?[0-9]?[0-9]<\/address>){1}',
  }
}