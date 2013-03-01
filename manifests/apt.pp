# == Class: apt
#
# Full description of class example_class here.
#
# === Parameters
#
# Document parameters here.
#
# [*ntp_servers*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*enc_ntp_servers*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { 'example_class':
#    ntp_servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@example.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class serverdensity::apt {

  file {
      'sd-agent.list':
          ensure  =>  file,
          path    => '/etc/apt/sources.list.d/sd-agent.list',
          source  => 'puppet:///modules/serverdensity/sd-agent.list',
          notify  => Exec['sd-apt-update']
  }

  exec {
      'add-sd-apt-key':
          command => '/usr/bin/wget -O - https://www.serverdensity.com/downloads/boxedice-public.key | /usr/bin/apt-key add -',
          require => File['sd-agent.list'],
  }

  exec {
      'sd-apt-update':
          command => '/usr/bin/apt-get update',
          require => Exec['add-sd-apt-key'],
  }

  package {
      'sd-agent':
          ensure  => 'present',
          require => Exec['sd-apt-update'],
  }
}
