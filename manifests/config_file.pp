# == Class: config_file
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
class serverdensity::config_file (
        $location = '',
        $sd_url = 'https://example.serverdensity.com',
        $agent_key = '',
        $plugin_directory = '',
        $apache_status_url = 'http://www.example.com/server-status/?auto',
        $apache_status_user = '',
        $apache_status_pass = '',
        $fpm_status_url = '',
        $mongodb_server = '',
        $mongodb_dbstats = 'no',
        $mongodb_replset = 'no',
        $mysql_server = '',
        $mysql_user = '',
        $mysql_pass = '',
        $nginx_status_url = '',
        $rabbitmq_status_url = 'http://www.example.com/nginx_status',
        $rabbitmq_user = 'guest',
        $rabbitmq_pass = 'guest',
        $tmp_directory = '/var/log/custom_location',
        $pidfile_directory = '/var/log/custom_location',
        $logging_level = 'fatal',
    ) {
    file { 'sd-agent-config-file':
        path    => $location,
        content => template('serverdensity/config.template'),
    }
}
