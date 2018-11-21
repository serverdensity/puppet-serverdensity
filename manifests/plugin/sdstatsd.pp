# == Class: serverdensity_agent::plugin::sdstatsd
#
# Defines the statsd plugin
# https://support.serverdensity.com/hc/en-us/articles/360001082706-Monitoring-with-SdStatsd 
#
class serverdensity_agent::plugin::sdstatsd {
  serverdensity_agent::plugin { 'sdstatsd':
    config_content => template('serverdensity_agent/plugin/sdstatsd.yaml.erb'),
  }
}
