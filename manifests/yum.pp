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

  file {
      'sd-agent.repo':
          ensure  =>  file,
          path    => '/etc/yum.repos.d/serverdensity.repo',
          content => '[serverdensity]
name=Server Density
baseurl=http://www.serverdensity.com/downloads/linux/redhat/
enabled=1',
  }

  file {
    'serverdensity-yum-key':
      path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-ServerDensity',
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/serverdensity/RPM-GPG-KEY-ServerDensity',
  }

  exec {
    'import-serverdensity-yum-key':
      command => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ServerDensity',
      unless  => "/bin/rpm -q gpg-pubkey-$(echo $(gpg --throw-keyids < /etc/pki/rpm-gpg/RPM-GPG-KEY-ServerDensity) | cut --characters=11-18 | tr '[A-Z]' '[a-z]')",
      refreshonly => true,
      logoutput => 'on_failure',
  }

  package {
      'sd-agent':
          ensure  => 'present',
  }

  File['serverdensity-yum-key'] ~> Exec['import-serverdensity-yum-key'] -> File['sd-agent.repo'] -> Package['sd-agent']
}
