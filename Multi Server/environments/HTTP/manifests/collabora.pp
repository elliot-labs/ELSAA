#
# Collabora Code Defs
#


# Only deploys the docker image if the Collabora CODE variable is enabled.
if $collabora_code {

   # Add Collabora Code Repository to APT
  apt::source { 'Collabora Code':
    comment  => 'This is the repository for Collabora CODE.',
    location => 'https://www.collaboraoffice.com/repos/CollaboraOnline/CODE',
    release  => './',
    key      => {
      id     => '0C54D189F4BA284D',
    },
  }

  # Ensure that the system is up to date with the above package list
  -> Class['apt::update']

  # Install CODE dependency.
  -> package { 'loolwsd': ensure => latest }

  # Install Collabora CODE itself.
  -> package { 'code-brand': ensure => latest }
}
