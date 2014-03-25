define serverdensity-agent::plugin (
	$pluginname = $title,     # The name for the plugin, it will be placed at $plugindir/$pluginname.py
	$content = undef,         # The file content of the plugin
	$source = undef,          # Alternate way of specifying the content with a puppet:// url
	$config = undef,          # A single level hash of key value pairs that will be placed under $configdir/$priority-$pluginname.cfg in the [$pluginname] section
	$config_priority = "500"  # Text to be pre-pended to the config filename to support ordering
) {

	include serverdensity-agent

	if $serverdensity-agent::location {
		$configdir = $serverdensity-agent::location
	} else {
		$configdir = "/etc/sd-agent/conf.d"
	}

	if $serverdensity-agent::plugin_directory {
		$plugindir = $serverdensity-agent::plugin_directory
	} else {
		$plugindir = "/usr/bin/sd-agent/plugins"
	}

	file { "sd_plugin_${title}":
		ensure  => "file",
		path    => "${plugindir}/${pluginname}.py",
		source  => $source,
		content => $content,
		owner   => "root",
		group   => "root",
		mode    => "0755",
		require => File["sd-agent-plugin-dir"],
		notify  => Service["sd-agent"],
	}

	if size(keys($config)) > 0 {
		file { "sd_config_${title}":
			ensure  => "file",
			path    => "${configdir}/${config_priority}-${pluginname}.cfg",
			content => template("serverdensity-agent/plugin/config.erb"),
			owner   => "root",
			group   => "root",
			mode    => "0644",
			require => File["sd-agent-config-dir"],
			before  => File["sd_plugin_${title}"],
		}
	}
}
