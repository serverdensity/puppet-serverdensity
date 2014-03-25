# == Define: serverdensity::plugin
#
# Defines serverdensity plugins
#
# === Parameters
#
# [*pluginname*]
#   String. The name for the plugin, it will be placed at $plugindir/$pluginname.py
#   Default: $title
#
# [*content*]
#   String. The file content of the plugin
#   Default: undef
#
# [*source*]
#   String. Alternate way of specifying the content with a puppet filebucket URI (puppet:///)
#   Default: undef
#
# [*config*]
#   Hashmap. A single level hash of key value pairs that will be placed under $configdir/$priority-$pluginname.cfg in the [$pluginname] section
#   Default: undef
#
# [*config_priority*]
#   Integer. Text to be pre-pended to the config filename to support ordering
#   Default: '500'
#
# === Examples
#
# serverdensity::plugin{ 'myplugin':
#   source    => 'puppet:///mymodule/myplugin.py',
#   config    => {
#     custom_key1   => 'foo',
#     custom_key2   => 1234,
#   }
# }
#
#
define serverdensity::plugin (
  $pluginname = $title,
  $content = undef,
  $source = undef,
  $config = undef,
  $config_priority = '500'
) {

  include serverdensity

  if $serverdensity::location {
    $configdir = $serverdensity::location
  } else {
    $configdir = '/etc/sd-agent/conf.d'
  }

  if $serverdensity::plugin_directory {
    $plugindir = $serverdensity::plugin_directory
  } else {
    $plugindir = '/usr/bin/sd-agent/plugins'
  }

  file { "sd_plugin_${title}":
    ensure  => file,
    path    => "${plugindir}/${pluginname}.py",
    source  => $source,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['sd-agent-plugin-dir'],
    notify  => Service['sd-agent'],
  }

  if size(keys($config)) > 0 {
    file { "sd_config_${title}":
      ensure  => file,
      path    => "${configdir}/${config_priority}-${pluginname}.cfg",
      content => template('serverdensity/plugin/config.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File['sd-agent-config-dir'],
      before  => File["sd_plugin_${title}"],
    }
  }
}
