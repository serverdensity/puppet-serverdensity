# == Class: serverdensity_agent::plugin::network
#
# Defines Network plugin configuration
#
# === Parameters
#
# [*excluded_interfaces*]
#   Array. Define network interfaces to be excluded
#   Default: ['lo','lo0']
#
# [*collect_connection_state*]
#   Boolean. Enable collection of connection states
#   Default: False
#
# [*excluded_interface_re*]
#   String, Define network interfaces to be excluded via regex
#   Default: undef
#
# [*combine_connection_states*]
#   Boolean. Enable combineing of connection states
#   Default: False
#
# === Examples
#
# class { 'serverdensity_agent::plugin::network':
#   excluded_interfaces => ['lo','lo0'],
#   collect_connection_state  => false,
#   excluded_interface_re => 'eth*',
#   combine_connection_states = false
# }
#
class serverdensity_agent::plugin::network (
    $excluded_interfaces = ['lo','lo0'],
    $collect_connection_state  = false,
    $excluded_interface_re = undef,
    $combine_connection_states = false
  ) {
  serverdensity_agent::plugin { 'network':
    config_content => template('serverdensity_agent/plugin/network.yaml.erb'),
  }
}
