# == Class: serverdensity_agent::plugin::sdstatsd
#
# Install the statsd plugin
# https://support.serverdensity.com/hc/en-us/articles/360001082706-Monitoring-with-SdStatsd 
#

class serverdensity_agent::plugin::sdstatsd () {
  serverdensity_agent::plugin { 'sdstatsd': }
}
