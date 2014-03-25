# == Class: serverdensity
#
# Base serverdensity class
#
# === Parameters
#
# [*sd_url*]
#   String. Subdomain url of the serverdensity account
#   Default: https://example.serverdensity.com
#
# [*api_token*]
#   String. Agent API token to use (for V2 API)
#   Default: ''
#
# [*api_username*]
#   String. Agent API username to use (for V1 API)
#   Default: ''
#
# [*api_password*]
#   String: Agent API password to use (for V1 API)
#   Default: ''
#
# [*use_fqdn*]
#   Boolean. Use the puppet FQDN fact rather than hostname
#   Default: false
#   Valid values: true, false
#
# [*agent_key*]
#   String. The unique key for the agent.
#   Default: $::agent_key (uses the provided agent_key library to generate a
#   new one if not set)
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
# [*apache_status_url*]
#   String. Url to the apache status page provided by the mod_status module
#   Default: http://www.example.com/server-status/?auto
#
# [*apache_status_user*]
#   String. Username required to access apache status URL
#   Default: ''
#
# [*apache_status_pass*]
#   String. Password required to access apache status URL
#   Default: ''
#
# [*fpm_status_url*]
#   String. URL to the phpfpm status page
#   Default: http://www.example.com/phpfpm_status
#
# [*mongodb_server*]
#   String. Server to get MongoDB status monitoring from. Takes a full MongoDB connection URI
#   Default: ''
#
# [*mongodb_dbstats*]
#   String. Enable MongoDB stats monitoring (only if $mongodb_server is also set)
#   Default: 'no'
#
# [*mongodb_replset*]
#   String. Enable MongoDB replica monitoring (only if $mongodb_server is also set)
#   Default: 'no'
#
# [*mysql_server*]
#   String. MySQL server to get status monitoring from
#   Default: ''
#
# [*mysql_user*]
#   String. Username to access MySQL server
#   Default: ''
#
# [*mysql_pass*]
#   String. Password required to access MySQL server
#   Default: ''
#
# [*nginx_status_url*]
#   String. URL to get nginx status (using HttpStubStatusModule)
#   Default: http://www.example.com/nginx_status
#
# [*rabbitmq_status_url*]
#   String. URL to rabbitmq status endpoint
#   Default: http://www.example.com:55672/json
#
# [*rabbitmq_user*]
#   String. Username required to access RabbitMQ status
#   Default: ''
#
# [*rabbitmq_pass*]
#   String. Password required to access RabbitMQ status
#   Default: ''
#
# [*tmp_directory*]
#   String. Directory where the agent stores temporary files. Defaults to system tmp
#   Default: ''
#
# [*pidfile_directory*]
#   String. Directory where agent stores its PID file. Defaults to $tmp_directory or system temp
#   Default: ''
#
# [*logging_level*]
#   String. Logging level to use for agent. Defaults to info if not set
#   Default: ''
#   Valid values: debug, info, warn, error, fatal
#
# [*manage_services*]
#   Boolean. Manage the sd-agent service. Useful when using an alternative process manager (e.g supervisor)
#   Default: true
#   Valid values: true, false
#
#
# === Examples
#
#  V2 API
#
#  class { 'serverdensity':
#    sd_url     => 'https://example.serverdensity.io',
#    api_token  => 'APITOKENHERE',
#  }
#
#
# === Authors
#
# David Mytton <david@serverdensity.com>
#
# === Copyright
#
# Copyright 2011 Server Density
#
class serverdensity(
class serverdensity (
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
  $manage_services = true,
  ) {

  if $plugin_directory {
    $sd_agent_plugin_dir = $plugin_directory
  } else {
    $sd_agent_plugin_dir = "/usr/bin/sd-agent/plugins"
  }

   case $::osfamily {
    'Debian': {
      include serverdensity::apt
        $location = '/etc/sd-agent/conf.d'

      file { 'sd-agent-plugin-dir':
        path    => $sd_agent_plugin_dir,
        ensure  => directory,
        mode    => "0755",
        notify  => Service['sd-agent'],
        notify  => Class['serverdensity::agent::service'],
        require => Class['serverdensity::apt'],
      }
    }
    'RedHat': {
      include serverdensity::yum
        $location = '/etc/sd-agent/conf.d'
      file { 'sd-agent-plugin-dir':
        path    => $sd_agent_plugin_dir,
        ensure  => directory,
        mode    => "0755",
        notify  => Service['sd-agent'],
        notify  => Class['serverdensity::agent::service'],
        require => Class['serverdensity::yum'],
      }
    }
    default: {
      fail("OSfamily ${::operatingsystem} not supported.")
    }
  }

  # Include everything and let each module determine its own state
  anchor { 'serverdensity::begin': } ->
  class { 'serverdensity::agent::service': } ->
  anchor {'serverdensity::end': }

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
      notify              => Class['serverdensity::agent::service']
  }
}
