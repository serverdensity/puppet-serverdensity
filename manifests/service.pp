# == Class: serverdensity_agent::service
#
# Manages the Server Density agent service
#
#

class serverdensity_agent::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $serverdensity_agent::service_enabled {
    $ensure = 'running'
    $enable = true
  }
  else {
    $ensure = 'stopped'
    $enable = false
  }

  service { 'sd-agent':
    ensure     => $ensure,
    enable     => $enable,
    name       => 'sd-agent',
    hasrestart => true,
    hasstatus  => false,
    subscribe  => Class['serverdensity_agent::config_file'],
  }

  # sdstatsd
  if $serverdensity_agent::use_sdstatsd {
    $ensure_sdstatsd = 'present'
  }
  else {
    $ensure_sdstatsd = 'absent'
  }
  package {
    'sd-agent-sdstatsd':
      ensure  => $ensure_sdstatsd,
  }
}
