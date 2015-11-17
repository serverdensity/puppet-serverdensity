serverdensity_agent
====================

Puppet Module for deploying the Server Density Agent and agent plugins

### Platforms

* Ubuntu
* CentOS

## Usage

This will create a new device, and then use the agent key provided automatically by the API to configure the agent on the node.

Create an API token by logging into your Server Density account, clicking your name top left, clicking Preferences then going to the Security tab.

```puppet
class {
        'serverdensity_agent':
            sd_url => 'https://example.serverdensity.io',
            api_token => 'APITOKENHERE',
}
```

### Fixed key config

This will install the agent, with the basic configuration, using the key that is provided.

```puppet
class {
        'serverdensity_agent':
            sd_url => 'https://example.serverdensity.io',
            agent_key => '1234567890abcdef',
    }
```

### Installing an agent plugin

This will upload a plugin, and add custom config for it.

```puppet
serverdensity_agent::plugin{ 'MyPlugin':
    source  => 'puppet:///mymodule/myplugin.py',
    config  => {
        custom_key1 => 'foo',
    }
}
```

NB - To access the value for `custom_key1` from your plugin script, you can read it from the rawConfig dict, e.g:

```python
def __init__(self, agentConfig, checksLogger, rawConfig):
    self.agentConfig = agentConfig
    self.checksLogger = checksLogger
    self.rawConfig = rawConfig
    # Grab the custom key
    self.key1 = self.rawConfig['MyPlugin']['custom_key1']
```

### Optional Parameters

There are some optional parameters that can be used to configure other parts of the agent

* `$use_fqdn` - This will cause the class to use the facter Fully Qualified Domain Name rather than the detected hostname. Useful in times where the sd-agent and puppet disagree on what the hostname should be.
* `$server_name`
* `$server_group` - Sets the group for the server that is added
* `$plugin_directory` -  Sets the directory the agent looks for plugins, if left blank it is ignored
* `$tmp_directory` - Override where the agent stores temporary files, system default tmp will be used if not set
* `$pidfile_directory` - Override where the agent stores it's PID file, temp dir (above or system default) is used if not set
* `$logging_level` - String. Logging level to use for agent. Defaults to INFO if not set.
* `$logtail_paths` - String. Specify path match patterns to tail the files to post back. Comma separated: e.g. `/var/log/apache2/*.log,/var/log/*.log`. You must enable this in your account first.
* `manage_services` - Allow puppet to manage the sd-agent service, default: true. Useful when using an alternative process manager, e.g supervisor
