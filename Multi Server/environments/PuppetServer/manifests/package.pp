#
# Package Defs
#

# Make sure that the puppet server software is up to date.
package { 'puppetserver' :
  ensure => latest,
}