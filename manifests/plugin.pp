# == Define: serverdensity_agent::plugin
#
# Defines serverdensity_agent plugins
#
# === Parameters
#
# [*pluginname*]
#   String. The name for the plugin, it will be placed
#   at $plugindir/$pluginname.py
#   Default: $title
#
# [*content*]
#   String. The file content of the plugin
#   Default: undef
#
# [*source*]
#   String. Alternate way of specifying the content with a puppet
#   filebucket URI (puppet:///)
#   Default: undef
#
# [*config*]
#   Hashmap. A single level hash of key value pairs that will be placed
#   under $configdir/$priority-$pluginname.cfg in the [$pluginname] section
#   Default: undef
#
# [*config_priority*]
#   Integer. Text to be pre-pended to the config filename to support ordering
#   Default: '500'
#
# === Examples
#
# serverdensity_agent::plugin{ 'myplugin':
#   source    => 'puppet:///mymodule/myplugin.py',
#   config    => {
#     custom_key1   => 'foo',
#     custom_key2   => 1234,
#   }
# }
#
#
define serverdensity_agent::plugin (
  $package = "sd-agent-${title}",
  $config_file = "/etc/sd-agent/conf.d/${title}.yaml",
  $config_content = ''
  ) {

  file { $config_file:
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $config_content,
    require => File['/etc/sd-agent/conf.d'],
    notify  => Class['serverdensity_agent::service'],
  }

  package { $package:
    ensure  => 'present',
    require => Package['sd-agent'],
    notify  => Class['serverdensity_agent::service'],
  }
}
