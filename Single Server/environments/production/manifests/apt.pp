if $javaPKG or $syncthingToggle {

  #Initialize APT class for use
  include apt

}

if $javaPKG {

  # Add WebUpd8 Team's java repository
  apt::ppa { 'ppa:webupd8team/java': }

}

if $syncthingToggle {
  apt::source { 'syncthing':
    comment  => 'This is the stable repository for syncthing.',
    location => 'https://apt.syncthing.net/',
    release  => 'syncthing',
    repos    => 'stable',
    key      => {
      id     => '37C84554E7E0A261E4F76E1ED26E6ED000654A3E',
      source => 'https://syncthing.net/release-key.txt',
    },
  }
}