if $minecraftToggle {

  # Logic that sets the config file for 5 second count down if the conditions are right.
  if $countDownToggle {
    $countDownText= "# Counts down from 5 seconds till server stop
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast Stopping server in 5...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast Stopping server in 4...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast Stopping server in 3...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast Stopping server in 2...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast Stopping server in 1...\\015\"\'
ExecStop=/bin/sleep 1"
  }

  # Makes sure that the Minecraft directory exists and manages permissions.
  file { 'Minecraft Dir':
    ensure => directory,
    path   => '/MC/',
    owner  => $user,
    group  => $group,
  }

  # Makes sure that the Spigot hosting directory is present.
  file { 'Spigot Dir':
    ensure  => directory,
    path    => '/MC/server/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'Minecraft Dir' ],
  }

  # Makes sure that the Spigot build directory is present.
  file { 'BuildTools Dir':
    ensure  => directory,
    path    => '/MC/buildtools/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'Minecraft Dir' ],
  }

  # Makes sure that the Spigot backup directory is present.
  file { 'Backups Dir':
    ensure  => directory,
    path    => '/MC/backups/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'Minecraft Dir' ],
  }

  # Makes sure that the temporary directory is present.
  file { 'Temp Dir':
    ensure  => directory,
    path    => '/MC/temp/',
    owner   => $user,
    group   => $group,
    recurse => true,
    require => File[ 'Minecraft Dir' ],
  }

  # ensures that the BuildTools file is present.
  file { 'BuildTools.jar':
    ensure  => file,
    path    => '/MC/buildtools/BuildTools.jar',
    owner   => $user,
    source  => 'file:///MC/temp/BuildTools.jar',
    require => [ Cron['Download BuildTools'], File['BuildTools Dir'], ],
  }

  # Automatically downloads the build tools once a week.
  cron { 'Download BuildTools':
    ensure  => present,
    user    => $user,
    command => '/usr/bin/wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar -O /MC/temp/BuildTools.jar',
    weekday => 'Friday',
  }

  # Creates a scheduled task that runs twice a week and creates the latest version of spigot when executed.
  cron { 'Build the spigot server':
    ensure  => present,
    name    => 'Build Spigot Server',
    command => "/usr/bin/java -jar /MC/builtools/BuildTools.jar --rev ${spigotVersion}",
    user    => $user,
    weekday => [ 'Monday', 'Thursday'],
  }

  # A resource that essentially check if a file changed. If it did change then it executes the server update.
  file { 'Spigot Executable Change Checker':
    ensure => present,
    path   => "/MC/temp/spigot-${spigotVersion}.jar",
    source => "file:///MC/buildtools/spigot-${spigotVersion}.jar",
    notify => Exec['Stop Spigot Server'],
  }

  # Stops the Spigot server service.
  exec { 'Stop Spigot Server':
    refreshonly => true,
    command     => '/usr/sbin/service spigot stop'
  }

  # Updates the executable file that the service relies upon.
  # After it has finished then it notifies the spigot service to start.
  -> file { 'update spigot file':
    path   => "/MC/server/spigot-${spigotVersion}.jar",
    source => "file:///MC/temp/spigot-${spigotVersion}.jar",
    notify => Service['Spigot Server'],
  }

  # Creates the systemd service configuration file
  file { 'Spigot Service Config':
    ensure  => file,
    path    => '/etc/systemd/system/spigot.service',
    content => "[Unit]
  Description=Spigot, A High Performance Minecraft Server.
  Documentation=http://minecraft.gamepedia.com/Tutorials/Setting_up_a_server
  Before=halt.target reboot.target shutdown.target

  [Service]
  Type=oneshot
  RemainAfterExit=true
  KillMode=none
  WorkingDirectory=/MC/server
  User=${user}

  ExecStart=/usr/bin/screen -d -m -S Spigot /usr/bin/java -Xmx${spigotMaxRAM} -Xms${spigotMinRAM} -jar spigot-${spigotVersion}.jar

  # Initial warnings about the impending server shutdown
  ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast ${serverStoppingAlert1}\\015\"\'
  ExecStop=/bin/sleep ${alertTime1}

  # Secondary warning about stopping the server.
  ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"broadcast ${serverStoppingAlert2}\\015\"\'
  ExecStop=/bin/sleep ${alertTime2}

  ${countDownText}

  # Actual server stop execution
  ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"stop\\015\"\'

  # If the server restart command is issued, how much downtime should there be in between stop and start
  # (Since there is no restart command for spigot)
  RestartSec=60

  [Install]
  WantedBy=multi-user.target",
  }

  # Automatically starts the spigot server on boot and makes sure that it is running when teh sstem is booted.
  service { 'Spigot Server':
    ensure  => running,
    name    => 'spigot',
    enable  => true,
    require => File['Spigot Service Config'],
  }
}