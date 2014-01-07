# == Class: serverdensity
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
class serverdensity(
  $sd_url = 'https://example.serverdensity.com',
  $api_token = '',
  $api_username = '',
  $api_password = '',
  $use_fqdn = false,
  $agent_key = $::agent_key,
  $server_name = '',
  $server_group = '',
  $plugin_directory = '',
  $apache_status_url = 'http://www.example.com/server-status/?auto',
  $apache_status_user = '',
  $apache_status_pass = '',
  $fpm_status_url = 'http://www.example.com/phpfpm_status',
  $mongodb_server = '',
  $mongodb_dbstats = 'no',
  $mongodb_replset = 'no',
  $mysql_server = '',
  $mysql_user = '',
  $mysql_pass = '',
  $nginx_status_url = 'http://www.example.com/nginx_status',
  $rabbitmq_status_url = 'http://www.example.com:55672/json',
  $rabbitmq_user = '',
  $rabbitmq_pass = '',
  $tmp_directory = '',
  $pidfile_directory = '',
  $logging_level = '',
  ) {
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      include apt
        $location = '/etc/sd-agent/config.cfg'
    }
    'RedHat', 'centos': {
      include yum
        $location = '/etc/sd-agent/config.cfg'
    }
    default: {
      fail("OSfamily ${::operatingsystem} not supported.")
    }
  }

  class {
    'config_file':
      location            => $location,
      require             => Package['sd-agent'],
      sd_url              => $sd_url,
      agent_key           => agent_key(
        $api_username,
        $api_password,
        $sd_url,
        $api_token,
        $agent_key,
        $server_name,
        $server_group,
        $use_fqdn
        ),
      plugin_directory    => $plugin_directory,
      apache_status_url   => $apache_status_url,
      apache_status_user  => $apache_status_user,
      apache_status_pass  => $apache_status_pass,
      fpm_status_url      => $fpm_status_url,
      mongodb_server      => $mongodb_server,
      mongodb_dbstats     => $mongodb_dbstats,
      mongodb_replset     => $mongodb_replset,
      mysql_server        => $mysql_server,
      mysql_user          => $mysql_user,
      mysql_pass          => $mysql_pass,
      nginx_status_url    => $nginx_status_url,
      rabbitmq_status_url => $rabbitmq_status_url,
      rabbitmq_user       => $rabbitmq_user,
      rabbitmq_pass       => $rabbitmq_pass,
      tmp_directory       => $tmp_directory,
      pidfile_directory   => $pidfile_directory,
      logging_level       => $logging_level,
      notify              => Service['sd-agent']
  }

  service {
    'sd-agent':
      ensure    => running,
      name      => 'sd-agent',
      pattern   => 'python /usr/bin/sd-agent/agent.py start init --clean',
      # due to https://bugs.launchpad.net/ubuntu/+source/upstart/+bug/552786
      hasstatus => false,
      enable    => true,
  }
}
