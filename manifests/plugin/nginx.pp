# == Class: serverdensity_agent::plugin::nginx
#
# Defines Nginx instances
#
# === Parameters
#
# [*nginx_status_url*]
#   String. Url to the nginx status page provided by the mod_status module
#   Default: http://localhost/nginx_status/
#
# [*ssl_validation*]
#   Boolean. Validate SSL
#   Default: undef
#
# === Examples
#
# class { 'serverdensity_agent::plugin::apache':
#   nginx_status_url => 'http://localhost/nginx_status/',
#   ssl_validation   => false,
#   }
# }
class serverdensity_agent::plugin::nginx (
  $nginx_status_url = 'http://localhost/nginx_status/',
  $ssl_validation = false,
  ) {
  serverdensity_agent::plugin { 'nginx':
    config_content => template('serverdensity_agent/plugin/nginx.yaml.erb'),
  }
}
