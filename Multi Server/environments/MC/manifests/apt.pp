if $javaPKG {

  # Initializes APT class for use
  include apt

  # Add Webupd8 Team's java repository
  apt::ppa { 'ppa:webupd8team/java': }

}
