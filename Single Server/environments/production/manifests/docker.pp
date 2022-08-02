#
# Docker Defs
#


# Only deploys the docker image if the Collabora CODE variable is enabled.
if $collaboraCode and $httpToggle {

  # Logic to add an escape charactor to all periods in the givin string.
  $dockerDomain = regsubst($codeDomain[1], '([.])', '\\\.', 'G')

  # Installs and configures the docker engine
  class { 'docker':
    manage_kernel    => false,
  }

  # Downloads the Collabora/Code image
  docker::image { 'collabora/code':
    image_tag => 'latest',
    }

  # Runs the collabora container. After image creation.
  -> docker::run { 'collabora_code':
    image            => 'collabora/code',
    ports            => ['127.0.0.1:9980:9980'],
    env              => ["domain=${dockerDomain}"],
    restart_service  => true,
    pull_on_start    => true,
    extra_parameters => [ '--cap-add MKNOD', '-t'],
  }
}