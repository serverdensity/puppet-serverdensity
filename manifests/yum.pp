# == Class: serverdensity_agent::yum
#
# Sets up the yum repository for the agent
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014 Server Density
#

class serverdensity_agent::yum {
  $repo_baseurl = 'http://archive.serverdensity.com/el/$releasever'

  # March 31, 2017 can't arrive soon enough
  if $operatingsystemrelease >= 5 and $operatingsystemrelease < 6 {
    $repo_keyurl = 'https://archive.serverdensity.com/sd-packaging-el5-public.key'
  } else {
    $repo_keyurl = 'https://archive.serverdensity.com/sd-packaging-public.key'
  }

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
