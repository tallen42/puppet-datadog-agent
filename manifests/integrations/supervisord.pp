# Class: datadog_agent::integrations::supervisord
#
# This class will install the necessary configuration for the supervisord integration
#
# See the sample supervisord.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/supervisord/datadog_checks/supervisord/data/conf.yaml.example
#
# Parameters:
#   servername
#   socket
#       Optional. The socket on which supervisor listen for HTTP/XML-RPC requests.
#   hostname
#       Optional. The host where supervisord server is running.
#   port
#       Optional. The port number.
#   username
#   password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#   proc_names
#       Optional. The process to monitor within this supervisord instance.
#       If not specified, the check will monitor all processes.
#   server_check
#       Optional. Service check for connections to supervisord server.
#
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::supervisord':
#   instances => [
#     {
#       servername => 'server0',
#       socket     => 'unix:///var/run//supervisor.sock',
#     },
#     {
#       servername => 'server1',
#       hostname   => 'localhost',
#       port       => '9001',
#       proc_names => ['java', 'apache2'],
#     },
#   ],
# }
#
#
#
class datadog_agent::integrations::supervisord (
  Array $instances = [{ 'servername' => 'server0', 'hostname' => 'localhost', 'port' => '9001' }],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/supervisord.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/supervisord.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
