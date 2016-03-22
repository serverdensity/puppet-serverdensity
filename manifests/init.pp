# == Class: serverdensity_agent
#
# Base serverdensity_agent class
#
# === Parameters
#
# [*agent_key*]
#   String. The unique key for the agent.
#   Default: $::sd_agent_key (uses the provided agent_key library to generate a
#   new one if not set)
#
# [*sd_account*]
#   String. Server Density account
#   Default: ''
#
# [*sd_url*]
#   String. Subdomain url of the Server Density account
#   Default: None
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
# [*v1_plugin_directory*]
#   String. The directory to install 3rd party legacy agent plugins to
#   Default: /usr/local/sd-agent-plugins
#
# [*log_level*]
#   String. Logging level to use for agent. Defaults to info if not set
#   Default: 'INFO'
#   Valid values: DEBUG, INFO, WARN, ERROR, FATAL
#
# [*service_enabled*]
#   Boolean. Ensures the sd-agent service is enabled and running through the
#            system service facility.
#   Default: true
#   Valid values: true, false
#
# === Examples
#
#  class { 'serverdensity_agent':
#    sd_account => 'example',
#    api_token  => 'APITOKENHERE',
#  }
#
#  class { 'serverdensity_agent':
#    sd_url     => 'https://example.agent.serverdensity.io',
#    api_token  => 'APITOKENHERE',
#  }
#
# === Authors
#
# Server Density <hello@serverdensity.com>
#
# === Copyright
#
# Copyright 2014-2015 Server Density
#

class serverdensity_agent(
  $agent_key = $::sd_agent_key,
  $sd_url = undef,
  $sd_account = '',
  $api_token = '',
  $use_fqdn = false,
  $server_name = '',
  $server_group = '',
  $proxy_host = undef,
  $proxy_port = undef,
  $proxy_user = undef,
  $proxy_password = undef,
  $proxy_forbid_method_switch = undef,
  $v1_plugin_directory = '/usr/local/sd-agent-plugins',
  $log_level = 'INFO',
  $collector_log_file = undef,
  $forwarder_log_file = undef,
  $log_to_syslog = undef,
  $syslog_host = undef,
  $syslog_port = undef,
  $service_enabled = true,
  ) {

  case $::osfamily {
    'Debian': {
      include serverdensity_agent::apt

      file { 'sd-agent-v1-plugin-dir':
        ensure  => directory,
        path    => $v1_plugin_directory,
        mode    => '0755',
        notify  => Class['serverdensity_agent::service'],
        require => Class['serverdensity_agent::apt'],
      }
    }
    'RedHat': {
      include serverdensity_agent::yum

      file { 'sd-agent-v1-plugin-dir':
        ensure  => directory,
        path    => $v1_plugin_directory,
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

  class { 'serverdensity_agent::config_file':
    api_token          => $api_token,
    provided_agent_key => $agent_key,
    server_name        => $server_name,
    server_group       => $server_group,
    v1_plugin_directory => $v1_plugin_directory,
    proxy_host          => $proxy_host,
    proxy_port          => $proxy_port,
    proxy_user          => $proxy_user,
    proxy_password      => $proxy_password,
    proxy_forbid_method_switch => $proxy_forbid_method_switch,
    use_fqdn           => $use_fqdn ,
    log_level          => $log_level,
    require            => Package['sd-agent'],
    sd_account         => $sd_account,
    notify             => Class['serverdensity_agent::service']
  }
}
