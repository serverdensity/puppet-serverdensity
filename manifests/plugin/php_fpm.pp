# == Class: serverdensity_agent::plugin::php_fpm
#
# Defines PHP-FPM instances
#
# === Parameters
#
# [*status_url*]
#   String. Url to the PHP-FPM pool status page
#   Default: http://localhost/status
#
# [*ping_url*]
#   String. Url to the PHP-FPM pool service to check FPM is alive and responding
#   Default: http://localhost/ping
#
# [*ping_reply*]
#   String. The expected reply from a pool to the ping url
#   Default: pong
#
# === Examples
#
# class { 'serverdensity_agent::plugin::php_fpm':
#   status_url => 'http://localhost/status',
# }
#
class serverdensity_agent::plugin::php_fpm (
  $status_url = 'http://localhost/status',
  $ping_url   = 'http://localhost/ping',
  $ping_reply = 'pong',
  ) {
  serverdensity_agent::plugin { 'php_fpm':
    config_content => template('serverdensity_agent/plugin/php_fpm.yaml.erb'),
  }
}
