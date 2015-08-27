# == Class: serverdensity_agent::freebsd
#
# Installs the sd-agent package
#

class serverdensity_agent::freebsd {
    # install SD agent package
    package { 'sd-agent':
        ensure  => present,
        require => Class['pkgng']
    }
}
