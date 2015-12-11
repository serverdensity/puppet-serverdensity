# == Class: serverdensity_agent::plugin::apache
#
# Defines Apache instances
#
# === Parameters
#
# [*apache_status_url*]
#   String. Url to the apache status page provided by the mod_status module
#   Default: http://localhost/server-status/?auto
#
# [*apache_user*]
#   String. Username required to access apache status URL
#   Default: undef
#
# [*apache_password*]
#   String. Password required to access apache status URL
#   Default: undef
#
# === Examples
#
# class { 'serverdensity_agent::plugin::apache':
#   apache_status_url => 'http://localhost/server-status?auto',
#   apache_user       => 'admin',
#   apache_password   => 'honshu'
# }
#
class serverdensity_agent::plugin::apache (
  $apache_status_url = 'http://localhost/server-status/',
  $apache_user = undef,
  $apache_password = undef,
  ) {
  serverdensity_agent::plugin { 'apache':
    config_content => template('serverdensity_agent/plugin/apache.yaml.erb'),
  }
}
