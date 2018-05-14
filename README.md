serverdensity_agent
====================

Puppet Module for deploying the Server Density Agent and agent plugins

### Platforms

* Amazon Linux
* CentOS
* RHEL
* Debian
* Ubuntu

> Support for Ubuntu Precise is now deprecated and agent updates are no longer provided after 2.1.6. This mainfest will install agent 2.1.6 for any server detected as Ubuntu Precise

## Usage

This will create a new device, and then use the agent key provided automatically by the API to configure the agent on the node.

Create an API token by logging into your Server Density account, clicking your name top left, clicking Preferences then going to the Security tab.

```puppet
class { 'serverdensity_agent':
    sd_account => 'example',
    api_token  => 'APITOKENHERE',
}
```

### Fixed key config

This will install the agent, with the basic configuration, using the key that is provided.

```puppet
class { 'serverdensity_agent':
    sd_account => 'example',
    agent_key  => '1234567890abcdef',
}
```

### Installing an agent plugin

This will upload a plugin, and add custom config for it.

```puppet
serverdensity_agent::plugin::v1{ 'MyPlugin':
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

* `use_fqdn` - This will cause the class to use the facter Fully Qualified Domain Name rather than the detected hostname. Useful in times where the sd-agent and puppet disagree on what the hostname should be.
* `server_name` - String. The reported name of the server
* `server_group` - Sets the group for the server that is added
* `v1_plugin_directory` - The directory to install 3rd party legacy agent plugins to
* `log_level` - String. Logging level to use for agent. Defaults to INFO if not set.
* `service_enabled` - Boolean. Ensures the sd-agent service is enabled and running through the system service facility, default: true. Useful when using an alternative process manager, e.g supervisor

## Upgrade to Server Density Agent Puppet Module 2.x

Many parameters have been deprecated and some have changed between the 0.9.x/1.x puppet module to the 2.x series. The 0.9.x series will be identified by 1.x. in this section

### sd_url changes and new sd_account parameter

- The `sd_url` parameter points to `https://accountname.agent.serverdensity.io/` instead of `https://accountname.serverdensity.io/`. Notice the `.agent` subdomain after the account name.
- The `sd_account` parameter is prefered over `sd_url`.

Hence the 1.x declaration:

```puppet
class { 'serverdensity_agent':
  sd_url    => 'https://example.serverdensity.io/',
  api_token => 'APITOKENHERE',
}
```

Should read in the 2.x version:

```puppet
class { 'serverdensity_agent':
  sd_url    => 'https://example.agent.serverdensity.io/',
  api_token => 'APITOKENHERE',
}
```

But the use of `sd_account` is preferred so this is the current best practice:

```puppet
class { 'serverdensity_agent':
  sd_account => 'example',
  api_token  => 'APITOKENHERE',
}
```

### Changed parameters
#### plugin_directory -> v1_plugin_directory

The name has changed and the default location has changed from `/usr/bin/sd-agent/plugins` to `/usr/local/sd-agent-plugins`.

#### logging_level -> log_level

Aesthetic change to maintain coherence with the v2 agent configuration file.

### Deprecated parameters
#### Deprecated by the serverdensity_agent::plugin::apache class

- apache_status_url
- apache_status_user
- apache_status_pass

Check the class documentation for further details. Basic example:

```puppet
class { 'serverdensity_agent::plugin::apache':
  apache_status_url => 'http://localhost/server-status?auto',
  apache_user       => 'admin',
  apache_password   => 'honshu'
}
```

#### Deprecated by the serverdensity_agent::plugin::mongo class

- mongodb_server
- mongodb_dbstats
- mongodb_replset

Check the class documentation for further details. Basic example:

```puppet
serverdensity_agent::plugin::mongo { 'mongodb://localhost:27017/admin': }
```

#### Deprecated by the serverdensity_agent::plugin::mysql class

- mysql_server
- mysql_user
- mysql_pass

Check the class documentation for further details. Basic example:

```puppet
class { 'serverdensity_agent::plugin::mysql':
  server   => 'localhost',
  user     => 'root',
  password => 'honshu'
}
```

Basic example with replication monitoring enabled:

```puppet
class { 'serverdensity_agent::plugin::mysql':
  server   => 'localhost',
  user     => 'root',
  password => 'honshu',
  repl     => true,
}
```

#### Deprecated by the serverdensity_agent::plugin::nginx class

- nginx_status_url

Check the class documentation for further details. Basic example:

```puppet
class { 'serverdensity_agent::plugin::nginx':
  nginx_status_url => 'http://localhost/nginx_status/',
  ssl_validation   => false,
}
```


#### Deprecated by the serverdensity_agent::plugin::rabbitmq class

- rabbitmq_status_url
- rabbitmq_user
- rabbitmq_pass

Check the class documentation for further details. Basic example:

```puppet
class { 'serverdensity_agent::plugin::rabbitmq':
  rabbitmq_api_url => 'http://localhost:55672/api/',
  rabbitmq_user    => 'guest',
  rabbitmq_pass    => 'guest'
}
```

#### Removed parameters
- api_username
- api_password
- fpm_status_url
- tmp_directory
- pidfile_directory
- logtail_paths

### New Classes
#### Disk
Check the class documentation for further details. Basic example:
```puppet
class { 'serverdensity_agent::plugin::disk':
    use_mount              => 'no',
    excluded_filesystems   => ['tmpfs', 'run'],
    excluded_disks         => ['/dev/sda', '/dev/sdb'],
    excluded_disk_re     => '/dev/sda.*',
    excluded_mountpoint_re => '/mnt/no-monitor.*',
    all_partitions         => false,
    tag_by_filesystem    => 'yes'
 }
 ```

#### Network
Check the class documentation for further details. Basic example:
```puppet
class { 'serverdensity_agent::plugin::network':
  excluded_interfaces => ['lo','lo0'],
  collect_connection_state  => true,
  excluded_interface_re => 'eth*',
  combine_connection_states => true
}
```

## Known issues

### Restart the puppet master on module upgrade

When using Puppet in infrastructure mode a restart of the Puppet master is needed to clean up the facter and custom functions caches.
