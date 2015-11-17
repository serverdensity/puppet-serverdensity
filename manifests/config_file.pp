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
  $location = '',
  $sd_url = 'https://example.serverdensity.io',
  $agent_key = '',
  $plugin_directory = '',
  $tmp_directory = '/var/log/custom_location',
  $pidfile_directory = '/var/log/custom_location',
  $logging_level = 'INFO',
  $logtail_paths = '',
  ) {

  file { 'sd-agent-config-dir':
    ensure => 'directory',
    path   => $location,
    mode   => '0755',
    notify => Class['serverdensity_agent::service'],
  }

  file { 'sd-agent-config-file':
    path    => "${location}/000-main.cfg",
    content => template('serverdensity_agent/config.cfg.erb'),
    mode    => '0644',
    notify  => Class['serverdensity_agent::service'],
  }
}
