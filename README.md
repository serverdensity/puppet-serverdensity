puppet-serverdensity
====================

Puppet Module for deploying the Server Density Agent

### Platforms

* Ubuntu
* CentOS

## Usage

### v2 API Config

*If your account URL ends in .io you are using v2*

This will create a new device, and then use the agent key provided automatically by the API to configure the agent on the node.

Create an API token by logging into your Server Density account, clicking your name top left, clicking Preferences then going to the Security tab.

```puppet
class {

        'serverdensity':
            sd_url => 'https://example.serverdensity.io',
            api_token => 'APITOKENHERE',
}
```
### v1 API Config

*If your account URL ends in .com you are using v1*

You can use the Server Density API to create a new device, based on the hostname of the node.

```puppet
class {
        'serverdensity':
            sd_url => 'https://example.serverdensity.com',
            api_username => 'username',
            api_password => 'password',
    }

```

### Fixed key config

This will install the agent, with the basic configuration, using the key that is provided.

```puppet
class {
        'serverdensity':
            sd_url => 'https://example.serverdensity.com',
            agent_key => '1234567890abcdef',
    }
```

### Optional Parameters

There are some optional parameters that can be used to configure other parts of the agent

* `$use_fqdn` - This will cause the class to use the facter Fully Qualified Domain Name rather than the detected hostname. Useful in times where the sd-agent and puppet disagree on what the hostname should be.
* `$server_name`
* `$server_group` - Sets the group for the server that is added
* `$plugin_directory` -  Sets the directory the agent looks for plugins, if left blank it is ignored
* `$apache_status_url` - URL to get the Apache2 status page from (e.g. `mod_status`), disabled if not set
* `$apache_status_user` - Username to authenticate to the Apache2 status page, required if `apache_status_url` is set
* `$apache_status_pass` - Password to authenticate to the Apache2 status page, required if `apache_status_url` is set
* `$fpm_status_url` - URL to get the PHP-FPM status page from, disabled if not set
* `$mongodb_server` - Server to get MongoDB status monitoring from, this takes a full [MongoDB connection URI](http://docs.mongodb.org/manual/reference/connection-string/) so you can set username/password etc. details here if needed, disabled if not set
* `$mongodb_dbstats` - Enables MongoDB stats if `true` and `mongodb_server` is set, *default*: `false`
* `$mongodb_replset` - Enables MongoDB replset stats if `true` and `mongodb_server` is set, *default*: `false`
* `$mysql_server` - Server to get MySQL status monitoring from, disabled if not set
* `$mysql_user` - Username to authenticate to MySQL, required if `mysql_server` is set
* `$mysql_pass` - Password to authenticate to MySQL, required if `mysql_server` is set
* `$nginx_status_url` - URL to get th Nginx status page from, disabled if not set
* `$rabbitmq_status_url` - URL to get the RabbitMQ status from via [HTTP management API](http://www.rabbitmq.com/management.html), disabled if not set
* `$rabbitmq_user` - Username to authenticate to the RabbitMQ management API, required if `rabbitmq_status_url` is set
* `$rabbitmq_pass` - Password to authenticate to the RabbitMQ management API, required if `rabbitmq_status_url` is set
* `$tmp_directory` - Override where the agent stores temporary files, system default tmp will be used if not set
* `$pidfile_directory` - Override where the agent stores it's PID file, temp dir (above or system default) is used if not set
