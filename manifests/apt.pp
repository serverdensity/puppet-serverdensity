# == Class: serverdensity_agent::apt
#
# Sets up the apt repository for the agent
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014 Server Density
#

class serverdensity_agent::apt {
  $repo_location = $::lsbdistcodename ? {
    'artful'  => 'xenial',
    'precise' => 'all',
    'quantal' => 'all',
    'raring'  => 'all',
    'saucy'   => 'all',
    'trusty'  => 'trusty',
    'utopic'  => 'trusty',
    'vivid'   => 'trusty',
    'wily'    => 'trusty',
    'yakkety' => 'xenial',
    'xenial'  => 'xenial',
    'zesty'   => 'xenial',
    'wheezy'  => 'wheezy',
    'jessie'  => 'jessie',
    'stretch' => 'stretch',
  }

  $repo_baseurl = "http://archive.serverdensity.com/${downcase($::lsbdistid)}"
  $repo_keyurl  = 'https://archive.serverdensity.com/sd-packaging-public.key'

  apt::source { 'serverdensity_agent':
    location => $repo_baseurl,
    release  => $repo_location,
    repos    => 'main',
    key      => {
      'id'     => '4381EE1BA673897A16AC92D43B2F6FF074371316',
      'source' => $repo_keyurl,
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
  }

  package {
    'sd-agent':
      ensure  => 'present',
      require => Apt::Source['serverdensity_agent'],
  }
}
