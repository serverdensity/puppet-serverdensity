# = Class: serverdensity::agent::service
#
# Manages the serverdensity agent service
#
class serverdensity::agent::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $serverdensity::manage_services {
    $ensure = 'running'
    $enable = true

    service { 'sd-agent':
      name        => 'sd-agent',
      ensure      => $ensure,
      enable      => $enable,
      # due to https://bugs.launchpad.net/ubuntu/+source/upstart/+bug/552786
      pattern     => 'python /usr/bin/sd-agent/agent.py start init --clean',
      hasrestart  => true,
      hasstatus   => false,
      subscribe   => [ Class['serverdensity::plugin'], Class['serverdensity::config_file'] ],
    }
  }
}
