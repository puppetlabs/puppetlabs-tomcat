# Definition: tomcat::config::server::connector
#
# Configure Connector elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $connector_ensure specifies whether you are trying to add or remove the
#   Connector element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - The $port attribute. This attribute is required unless $connector_ensure
#   is set to false.
# - The $protocol attribute. Defaults to $name when not specified.
# - $parent_service is the Service element this Connector should be nested
#   beneath. Defaults to 'Catalina'.
# - An optional hash of $additional_attributes to add to the Connector. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::server::connector (
  $catalina_base         = $::tomcat::catalina_home,
  $connector_ensure      = 'present',
  $port                  = undef,
  $protocol              = undef,
  $parent_service        = 'Catalina',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($connector_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)

  if $protocol {
    $_protocol = $protocol
  } else {
    $_protocol = $name
  }

  $base_path = "Server/Service[#attribute/name='${parent_service}']/Connector[#attribute/protocol='${_protocol}']"

  if $connector_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    if ! $port {
      fail('$port must be specified if you aren\'t removing the connector')
    }

    $_protocol_change = "set ${base_path}/#attribute/protocol ${_protocol}"
    $_port = "set ${base_path}/#attribute/port ${port}"
    if ! empty($additional_attributes) {
      $_additional_attributes = prefix(join_keys_to_values($additional_attributes, ' '), "set ${base_path}/#attribute/")
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    }

    $changes = delete_undef_values(flatten([$_protocol_change, $_port, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "server-${catalina_base}-${parent_service}-connector-${_protocol}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/server.xml",
    changes => $changes,
  }
}
