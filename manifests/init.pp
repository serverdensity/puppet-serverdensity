class sd-apt {

    file {
        'sd-agent.list':
            path    => '/etc/apt/sources.list.d/sd-agent.list',
            ensure  =>  file,
            content => 'deb http://www.serverdensity.com/downloads/linux/deb all main',
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
            ensure => 'present',
            require => Exec['sd-apt-update']
    }    
}

class sd-yum {

    file {
        'sd-agent.repo':
            path    => '/etc/yum.repos.d/serverdensity.repo',
            ensure  =>  file,
            content => '[serverdensity]
name=Server Density
baseurl=http://www.serverdensity.com/downloads/linux/redhat/
enabled=1',
    }

    exec {
        'download-sd-yum-key':
            command => '/usr/bin/wget https://www.serverdensity.com/downloads/boxedice-public.key',
            require => File['sd-agent.repo'],
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

class sd-config-file ( 
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

class puppet-serverdensity( 
    $sd_url,
    $api_token = '',
    $api_username = '',
    $api_password = '',
    $agent_key = '',
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
                agent_key => agent_key('1', 'puppettest', 'testpuppet', 'tomwardill.serverdensity.com', ''),
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
            ensure  => "running",
            enable  => "true",
    }
}