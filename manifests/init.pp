# == Class: apt
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
class apt {

    file {
        'sd-agent.list':
            ensure  =>  file,
            path    => '/etc/apt/sources.list.d/sd-agent.list',
            source  => 'puppet:///modules/puppet-serverdensity/sd-agent.list',
            notify  => Exec['sd-apt-update']
    }

    exec {
        'add-sd-apt-key':
            command => '/usr/bin/wget -O - https://www.serverdensity.com/downloads/boxedice-public.key | /usr/bin/apt-key add -',
            require => File['sd-agent.list'],
    }

    exec {
        'sd-apt-update':
            command => '/usr/bin/apt-get update',
            require => Exec['add-sd-apt-key'],
    } 

    package {
        'sd-agent':
            ensure  => 'present',
            require => Exec['sd-apt-update'],
    }    
}

class sd_yum {

    file {
        'sd-agent.repo':
            ensure  =>  file,
            path    => '/etc/yum.repos.d/serverdensity.repo',
            content => '[serverdensity]
name=Server Density
baseurl=http://www.serverdensity.com/downloads/linux/redhat/
enabled=1',
    }

    package {
        'wget':
            ensure => 'present',
    }

    exec {
        'download-sd-yum-key':
            command => '/usr/bin/wget https://www.serverdensity.com/downloads/boxedice-public.key',
            require => [File['sd-agent.repo'], Package['wget']],
    }

    exec {
        'import-sd-yum-key':
            command => '/usr/bin/sudo rpm --import boxedice-public.key',
            require => Exec['download-sd-yum-key'],
    }

    exec {
        'delete-sd-yum-key':
            command => '/bin/rm boxedice-public.key',
            require => Exec['import-sd-yum-key'],
    }

    package {
        'sd-agent':
            ensure => 'present',
            require => Exec['delete-sd-yum-key']
    } 
}

class sd_config_file ( 
        $location,
        $sd_url,
        $agent_key,
        $plugin_directory,
        $apache_status_url,
        $apache_status_user,
        $apache_status_pass,
        $mongodb_server,
        $mongodb_dbstats,
        $mongodb_replset,
        $mysql_server,
        $mysql_user,
        $mysql_pass,
        $nginx_status_url,
        $rabbitmq_status_url,
        $rabbitmq_user,
        $rabbitmq_pass,
        $tmp_directory,
        $pidfile_directory,
        $logging_level
    ) {
    file { 'sd-agent-config-file':
        path => $location,
        content => template('puppet-serverdensity/config.template'),
        
    }
}

class serverdensity( 
    $sd_url,
    $api_token = '',
    $api_username = '',
    $api_password = '',
    $agent_key = '',
    $server_name = '',
    $plugin_directory = '',
    $apache_status_url = 'http://www.example.com/server-status/?auto',
    $apache_status_user = '',
    $apache_status_pass = '',
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
    $logging_level = ''
) {

    case $::operatingsystem {
        'Ubuntu': { 
            include sd-apt
            $location = '/etc/sd-agent/config.cfg'
        }
        'CentOS': { 
            include sd-yum 
            $location = '/etc/sd-agent/config.cfg'
        }
    }

    class {
           'sd-config-file':
                location => $location,
                require => Package['sd-agent'],
                sd_url => $sd_url,
                agent_key => agent_key($api_username, $api_password, $sd_url, $api_token, $agent_key, $server_name),
                plugin_directory => $plugin_directory,
                apache_status_url => $apache_status_url,
                apache_status_user => $apache_status_user,
                apache_status_pass => $apache_status_pass,
                mongodb_server => $mongodb_server,
                mongodb_dbstats => $mongodb_dbstats,
                mongodb_replset => $mongodb_replset,
                mysql_server => $mysql_server,
                mysql_user => $mysql_user,
                mysql_pass => $mysql_pass,
                nginx_status_url => $nginx_status_url,
                rabbitmq_status_url => $rabbitmq_status_url,
                rabbitmq_user => $rabbitmq_user,
                rabbitmq_pass => $rabbitmq_pass,
                tmp_directory => $tmp_directory,
                pidfile_directory => $pidfile_directory,
                logging_level => $logging_level,

                notify => Service['sd-agent']
    }

    service {
        'sd-agent':
            ensure  => 'running',
            enable  => true,
    }
}
