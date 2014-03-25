class serverdensity-agent(
  $sd_url = 'https://example.serverdensity.io',
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
        require => Class['serverdensity::yum'],
      }
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
