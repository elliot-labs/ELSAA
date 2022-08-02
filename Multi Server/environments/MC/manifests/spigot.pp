#
# Spigot/Minecraft Server Defs
#

# Makes sure that the Minecraft directories exists and manages permissions for all of them.
file { $mcDirs:
  ensure => directory,
  owner  => $user,
  group  => $group,
}

# Download the initial BuildTools file and trigger an initial build.
exec { 'Initial BuildTools jar':
  creates => "${mcBaseDir}/${mcBuildToolsDir}/BuildTools.jar",
  command => "/usr/bin/wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar -O ${mcBaseDir}/${mcBuildToolsDir}/BuildTools.jar",
  require => File[$mcDirs],
  user    => $user,
  notify  => Exec['Initial Spigot Build'],
}

# Ensure that the Java package is installed before executing the build command.
# Detects the version of Java selected by the admin and then execute based upon that.
if $javaPKG {
  # Build a new version of the spigot server
  exec { 'Initial Spigot Build':
    refreshonly => true,
    command     => "/usr/bin/java -jar ${mcBaseDir}/${mcBuildToolsDir}/BuildTools.jar --rev ${spigotVersion}",
    user        => $user,
    cwd         => "${mcBaseDir}/${mcBuildToolsDir}/",
    environment => ["HOME=${mcBaseDir}/${mcBuildToolsDir}"],
    timeout     => 0,
    require     => Package['oracle-java8-installer'],
  }
}
else {
  # Build a new version of the spigot server
  exec { 'Initial Spigot Build':
    refreshonly => true,
    command     => "/usr/bin/java -jar ${mcBaseDir}/${mcBuildToolsDir}/BuildTools.jar --rev ${spigotVersion}",
    user        => $user,
    cwd         => "${mcBaseDir}/${mcBuildToolsDir}/",
    environment => ["HOME=${mcBaseDir}/${mcBuildToolsDir}"],
    timeout     => 0,
    require     => Package['openjdk-8-jre'],
  }
}

# Automatically downloads the build tools once a week.
cron { 'Download BuildTools':
  ensure  => present,
  user    => $user,
  command => "/usr/bin/wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar -O ${mcBaseDir}/${mcTempDir}/BuildTools.jar",
  weekday => 'Friday',
  require => File[$mcDirs],
}

# Creates a scheduled task that runs twice a week and creates the latest version of spigot when executed.
# This is only created when the initial BuildTools jar file is downloaded and the directories are created.
cron { 'Build the spigot server':
  ensure      => present,
  name        => 'Build Spigot Server',
  command     => "/usr/bin/java -jar ${mcBaseDir}/${mcBuildToolsDir}/BuildTools.jar --rev ${spigotVersion}",
  environment => ["HOME=${mcBaseDir}/${mcBuildToolsDir}"],
  user        => $user,
  weekday     => [ 'Monday', 'Thursday'],
  require     => [
    File[$mcDirs],
    Exec['Initial BuildTools jar'],
  ],
}

# Logic that sets the config file for 5 second count down if enabled in the config file.
if $countdownToggle {
  $countdownText= "# Counts down from 5 seconds till server stop
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} Stopping server in 5...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} Stopping server in 4...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} Stopping server in 3...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} Stopping server in 2...\\015\"\'
ExecStop=/bin/sleep 1
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} Stopping server in 1...\\015\"\'
ExecStop=/bin/sleep 1"
}
else {
  $countdownText=''
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
WorkingDirectory=${mcBaseDir}/${mcServerDir}
User=${user}

ExecStart=/usr/bin/screen -d -m -S Spigot /usr/bin/java -Xmx${spigotMaxRAM} -Xms${spigotMinRAM} -jar spigot-${spigotVersion}.jar

# Initial warnings about the impending server shutdown
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} ${serverStoppingAlert1}\\015\"\'
ExecStop=/bin/sleep ${alertTime1}

# Secondary warning about stopping the server.
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"${mcChatCommand} ${serverStoppingAlert2}\\015\"\'
ExecStop=/bin/sleep ${alertTime2}

${countdownText}

# Actual server stop execution
ExecStop=/usr/bin/screen -S Spigot -X eval \'stuff \"stop\\015\"\'

# If the server restart command is issued, how much downtime should there be in between stop and start
# (Since there is no restart command for spigot)
RestartSec=60

[Install]
WantedBy=multi-user.target",
}

# Stops the Spigot server service.
# Can only be executed if the service config file exists.
exec { 'Stop Spigot Server':
  refreshonly => true,
  command     => '/usr/sbin/service spigot stop',
  require     => File['Spigot Service Config'],
}

# Automatically starts the spigot server on boot and makes sure that it is running when the system is booted.
# Only manage the service if the config file exists.
service { 'Spigot Server':
  ensure  => running,
  name    => 'spigot',
  enable  => true,
  require => File['Spigot Service Config'],
}

# A resource that essentially check if a file changed. If it did change then it executes the server update.
file { 'Spigot Executable Change Checker':
  ensure => present,
  path   => "${mcBaseDir}/${mcTempDir}/spigot-${spigotVersion}.jar",
  source => "file://${mcBaseDir}/${mcBuildToolsDir}/spigot-${spigotVersion}.jar",
  notify => Exec['Stop Spigot Server'],
  require => [
    File[$mcDirs],
    Cron['Build the spigot server'],
  ],
}

# updates the executable file that the service relies upon.
# After it has finished then it notifies the spigot service to start.
file { 'Update Spigot File':
  path    => "${mcBaseDir}/${mcServerDir}/spigot-${spigotVersion}.jar",
  source  => "file://${mcBaseDir}/${mcTempDir}/spigot-${spigotVersion}.jar",
  notify  => Service['Spigot Server'],
  require => File['Spigot Executable Change Checker'],
}
