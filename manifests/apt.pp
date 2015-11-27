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
  $repo_baseurl = 'http://archive.serverdensity.com/ubuntu'
  $repo_keyurl = 'https://archive.serverdensity.com/sd-packaging-public.key'

  apt::source { 'serverdensity_agent':
    location    => $repo_baseurl,
    release     => 'all',
    repos       => 'main',
    key         => '4381EE1BA673897A16AC92D43B2F6FF074371316',
    key_source  => $repo_keyurl,
    include_src => false
  }
  package {
    'sd-agent':
      ensure  => 'present',
      require => Apt::Source['serverdensity_agent'],
  }
}
