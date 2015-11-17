# == Class: serverdensity_agent
#
# Base serverdensity_agent class
#
# === Parameters
#
# [*agent_key*]
#   String. The unique key for the agent.
#   Default: $::agent_key (uses the provided agent_key library to generate a
#   new one if not set)
#
# [*sd_url*]
#   String. Subdomain url of the serverdensity account
#   Default: https://example.serverdensity.io
#
# [*api_token*]
#   String. Agent API token to use (for V2 API)
#   Default: ''
#
# [*use_fqdn*]
#   Boolean. Use the puppet FQDN fact rather than hostname
#   Default: false
#   Valid values: true, false
#
# [*server_name*]
#   String. The reported name of the server
#   Default: ''
#
# [*server_group*]
#   String. The server group to assign this host to
#   Default: ''
#
# [*plugin_directory*]
#   String. The directory to install agent plugins to
#   Default: /usr/bin/sd-agent/plugins
#
# [*tmp_directory*]
#   String. Directory where the agent stores temporary files.
#   Defaults to system tmp if unset
#   Default: ''
#
# [*pidfile_directory*]
#   String. Directory where agent stores its PID file. Defaults to
#   $tmp_directory or system temp
#   Default: ''
#
# [*logging_level*]
#   String. Logging level to use for agent. Defaults to info if not set
#   Default: 'INFO'
#   Valid values: DEBUG, INFO, WARN, ERROR, FATAL
#
# [*logtail_paths*]
#   String. Specify path match patterns to tail the files to post back
#   Default: ''
#
# [*service_enabled*]
#   Boolean. Ensures the sd-agent service is enabled and running through the system service facility.
#   Default: true
#   Valid values: true, false
#
#
# === Examples
#
#  V2 API
#
#  class { 'serverdensity_agent':
  #    sd_url     => 'https://example.serverdensity.io',
  #    api_token  => 'APITOKENHERE',
  #  }
#
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014 Server Density
#

class serverdensity_agent(
  $agent_key = $::agent_key,
  $sd_url = 'https://example.serverdensity.io',
  $api_token = '',
  $use_fqdn = false,
  $server_name = '',
  $server_group = '',
  $plugin_directory = '/usr/bin/sd-agent/plugins',
  $tmp_directory = '',
  $pidfile_directory = '',
  $logging_level = 'INFO',
  $logtail_paths = '',
  $service_enabled = true,
  ) {

  case $::osfamily {
    'Debian': {
      include serverdensity_agent::apt

      file { 'sd-agent-plugin-dir':
        ensure  => directory,
        path    => $plugin_directory,
        mode    => '0755',
        notify  => Class['serverdensity_agent::service'],
        require => Class['serverdensity_agent::apt'],
      }
    }
    'RedHat': {
      include serverdensity_agent::yum

      file { 'sd-agent-plugin-dir':
        ensure  => directory,
        path    => $plugin_directory,
        mode    => '0755',
        notify  => Class['serverdensity_agent::service'],
        require => Class['serverdensity_agent::yum'],
      }
    }
    default: {
      fail("OSfamily ${::operatingsystem} not supported.")
    }
  }

  # Include everything and let each module determine its own state
  anchor { 'serverdensity_agent::begin': } ->
  class { 'serverdensity_agent::service': } ->
  anchor {'serverdensity_agent::end': }

  class {'serverdensity_agent::config_file':
      require             => Package['sd-agent'],
      sd_url              => $sd_url,
      agent_key           => agent_key(
        $sd_url,
        $api_token,
        $agent_key,
        $server_name,
        $server_group,
        $use_fqdn ),
      plugin_directory    => $plugin_directory,
      tmp_directory       => $tmp_directory,
      pidfile_directory   => $pidfile_directory,
      logging_level       => $logging_level,
      logtail_paths       => $logtail_paths,
      notify              => Class['serverdensity_agent::service']
  }
}
