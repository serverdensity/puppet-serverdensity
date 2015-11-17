# == Class: serverdensity_agent::config_file
#
# Defines the agent config file
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014 Server Density
#

class serverdensity_agent::config_file (
  $sd_url = 'https://example.serverdensity.io',
  $agent_key = '',
  $proxy_host = undef,
  $proxy_port = undef,
  $proxy_user = undef,
  $proxy_password = undef,
  $proxy_forbid_method_switch = undef,
  $server_name = undef,
  $plugin_directory = '',
  $log_level = undef,
  $collector_log_file = undef,
  $forwarder_log_file = undef,
  $log_to_syslog = undef,
  $syslog_host = undef,
  $syslog_port = undef,
  ) {

  file { '/etc/sd-agent/conf.d':
    ensure => 'directory',
    mode   => '0755',
    notify => Class['serverdensity_agent::service'],
  }

  file { '/etc/sd-agent/config.cfg':
    content => template('serverdensity_agent/config.cfg.erb'),
    ensure  => 'file',
    mode    => '0644',
    notify  => Class['serverdensity_agent::service'],
  }
}
