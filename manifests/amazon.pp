# == Class: serverdensity_agent::amazon
#
# Sets up the yum repository for the agent on amazon linux servers
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014 Server Density
#

class serverdensity_agent::amazon {
  $repo_baseurl = "http://archive.serverdensity.com/el/6"
  $repo_keyurl = 'https://archive.serverdensity.com/sd-packaging-public.key'

  yumrepo { 'serverdensity_agent':
    baseurl  => $repo_baseurl,
    gpgkey   => $repo_keyurl,
    descr    => 'Server Density',
    enabled  => 1,
    gpgcheck => 1,
  }
  # install SD agent package
  package { 'sd-agent':
    ensure  => present,
    require => Yumrepo['serverdensity_agent']
  }
}
