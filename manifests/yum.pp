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
  $repo_baseurl = "https://archive.serverdensity.com/el/${::operatingsystemmajrelease}"

  # March 31, 2017 can't arrive soon enough
  if $::operatingsystemmajrelease >= '5' and $::operatingsystemmajrelease < '6' {
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

  if $::operatingsystemmajrelease >= '6' and $::operatingsystemmajrelease < '7' {
    package { 'epel-release':
      ensure   => installed,
      provider => 'rpm',
      source   => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm'
    }
    if downcase($::lsbdistid) == 'centos' {
      $location = downcase($::lsbdistid)
    }
    else {
      $location = 'rhel'
    }
    package { 'ius-release':
      ensure   => installed,
      provider => 'rpm',
      source   => "https://${location}6.iuscommunity.org/ius-release.rpm"
    }
  }

  # install SD agent package
  package { 'sd-agent':
    ensure  => present,
    require => Yumrepo['serverdensity_agent']
  }
}
