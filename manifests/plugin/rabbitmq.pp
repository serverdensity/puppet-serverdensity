# == Class: serverdensity_agent::plugin::rabbitmq
#
# Defines Rabbitmq instances
#
# === Parameters
#
# [*rabbitmq_api_url*]
#   String. Url to the rabbitmq API URL
#   Default: http://localhost:55672/api/
#
# [*rabbitmq_user*]
#   String. Username required to access rabbitmq API
#   Default: 'guest'
#
# [*rabbitmq_pass*]
#   String. Password required to access rabbitmq API
#   Default: 'guest'
#
# === Examples
#
# class { 'serverdensity_agent::plugin::rabbitmq':
#   rabbitmq_api_url => 'http://localhost:55672/api/',
#   rabbitmq_user    => 'guest',
#   rabbitmq_pass    => 'guest'
#   }
# }
class serverdensity_agent::plugin::rabbitmq (
  $rabbitmq_api_url = 'http://localhost:55672/api/',
  $rabbitmq_user = 'guest',
  $rabbitmq_pass = 'guest',
  ) {
  serverdensity_agent::plugin { 'rabbitmq':
    config_content => template('serverdensity_agent/plugin/rabbitmq.yaml.erb'),
  }
}
