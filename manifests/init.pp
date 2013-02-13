class apt {

    file {
        'sd-agent.list':
            path    => '/etc/apt/sources.list.d/sd-agent.list',
            ensure  =>  file,
            content => 'deb http://www.serverdensity.com/downloads/linux/deb all main',
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

class yum {
    
}

class puppet-serverdensity( $content ) {
    case $::operatingsystem {
        'Ubuntu': { include apt }
        'CentOS'
    }
}