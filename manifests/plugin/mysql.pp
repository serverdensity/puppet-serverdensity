# == Class: serverdensity_agent::plugin::mysql
#
# Defines Mysql instances
#
# === Parameters
#
# [*server*]
#   String. Url to the mysql status page provided by the mod_status module
#   Default: 'localhost'
#
# [*user*]
#   String. Username to access mysql L
#   Default: 'root'
#
# [*pass*]
#   String. Password required to access mysql 
#   Default: undef
#
# [*port*]
#   String. Port of the MySQL daemon
#   Default: undef
#
# [*sock*]
#   String. Path of the unix socket if that is the method to connect
#   Default: undef
#
# [*repl*]
#   Boolean. Whether replication monitoring should be enabled
#   Default: False
#
# [*defaults_file*]
#   String. Path to a my.cnf to use as alternate configuration mechanism
#   Default: undef
#
# === Examples
#
# class { 'serverdensity_agent::plugin::mysql':
#   server   => 'localhost',
#   user     => 'root',
#   password => 'honshu'
# }
#
class serverdensity_agent::plugin::mysql (
  $server = 'localhost',
  $user = 'root',
  $pass = undef,
  $port = undef,
  $sock = undef,
  $repl = false,
  $defaults_file = undef,
  ) {
  serverdensity_agent::plugin { 'mysql':
    config_content => template('serverdensity_agent/plugin/mysql.yaml.erb'),
  }
}
