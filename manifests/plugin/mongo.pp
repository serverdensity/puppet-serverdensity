# == Class: serverdensity_agent::plugin::mongo
#
# Defines a MongoDB instance
#
# === Parameters
#
# [*server*]
#   String. Specify the MongoDB URI, with database to use for reporting
#   Default: none
#
# [*ssl*]
#   Boolean. Enable SSL connection
#   Default: none
#
# [*ssl_keyfile*]
#   String. Path to the private keyfile used to identify the agent.
#   Default: none
#
# [*ssl_certfile*]
#   String. Path to the certificate file used to identify the local connection
#           against mongod.
#   Default: none
#
# [*ssl_cert_reqs*]
#   String. Specifies whether a certificate is required from the other side of
#           the connection, and whether it will be validated if provided.
#   Default: none
#
# [*ssl_ca_carts*]
#   String. Path to the ca_certs file.
#   Default: none
#
# === Examples
#
# serverdensity_agent::plugin::mongo { 'mongodb://localhost:27017/admin': }
#  
class serverdensity_agent::plugin::mongo (
  $server = 'mongodb://localhost:27017/admin',
  $ssl = undef,
  $ssl_keyfile = undef,
  $ssl_certfile = undef,
  $ssl_cert_reqs = undef,
  $ssl_ca_certs = undef,
  ) {
  serverdensity_agent::plugin { 'mongo':
    config_content => template('serverdensity_agent/plugin/mongo.yaml.erb'),
  }
}
