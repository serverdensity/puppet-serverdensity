# == Class: serverdensity_agent::plugin::sdstatsd
#
# Defines the statsd plugin
# https://support.serverdensity.com/hc/en-us/articles/360001082706-Monitoring-with-SdStatsd 
#
# === Parameters
#
# [*statsd_forward_host*]
#   String. Hostname of the external statsd server.
#   Default: undef
#
# [*statsd_forward_port*]
#   String. Port of the external statsd server.
#   Default: undef
#

class serverdensity_agent::plugin::sdstatsd (
    $statsd_forward_host = undef,
    $statsd_forward_port = undef,
  ) {
  serverdensity_agent::plugin { 'sdstatsd':
    config_content => template('serverdensity_agent/plugin/sdstatsd.yaml.erb'),
  }
}
