# == Class: yum
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
class serverdensity::yum {
  $repo_baseurl = 'http://www.serverdensity.com/downloads/linux/redhat/'
  $repo_keyurl = 'https://www.serverdensity.com/downloads/boxedice-public.key'

  yumrepo { 'serverdensity':
    baseurl  => $repo_baseurl,
    gpgkey   => $repo_keyurl,
    descr    => "Server Density",
    enabled  => 1,
    gpgcheck => 1,
  }
  # install SD agent package
  package { 'sd-agent':
    ensure   => present,
    require  => Yumrepo['serverdensity']
  }
}
