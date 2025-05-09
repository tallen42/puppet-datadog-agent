# Class: datadog_agent::integrations::snmp
#
# This class will enable snmp check
#
# See the sample snmp.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/snmp/datadog_checks/snmp/data/conf.yaml.example
#
# Parameters:
#   $init_config:
#       Optional hash (see snmp.yaml.example for reference)
#
#   $instances:
#        Array of hashes containing snmp instance configuration (see snmp.yaml.example for reference)
#
#   $mibs_folder: (Deprecated in favor of $init_config)
#   $ignore_nonincreasing_oid: (Deprecated in favor of $init_config)
#   $snmp_v1_instances: (Deprecated in favor of $instances)
#   $snmp_v2_instances: (Deprecated in favor of $instances)
#   $snmp_v3_instances: (Deprecated in favor of $instances)
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::snmp':
#     instances => [
#       {
#         ip_address       => 'localhost',
#         port             => 161,
#         community_string => 'public',
#         tags             => [
#           'optional_tag_1',
#         ],
#         metrics          => [
#           {
#             MIB         => 'IF-MIB',
#             table       => 'ifTable',
#             symbols     => [
#               'ifInOctets',
#               'ifOutOctets',
#             ],
#             metric_tags => [
#               {
#                 tag    => 'interface',
#                 column => 'ifDescr',
#               },
#               {
#                 tag    => 'interface_index',
#                 column => 'ifIndex',
#               },
#             ],
#           },
#         ],
#       }
#     ],
#   }
class datadog_agent::integrations::snmp (
  Optional[Any] $mibs_folder        = undef,
  Boolean $ignore_nonincreasing_oid = false,
  Hash $init_config                 = {},
  Array[Hash] $instances            = [],
  Array $snmp_v1_instances          = [],
  Array $snmp_v2_instances          = [],
  Array $snmp_v3_instances          = [],
) inherits datadog_agent::params {
  require datadog_agent

  $versioned_instances = {
    1 => $snmp_v1_instances,
    2 => $snmp_v2_instances,
    3 => $snmp_v3_instances,
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/snmp.d"

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
    content => template('datadog_agent/agent-conf.d/snmp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
