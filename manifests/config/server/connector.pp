define tomcat::config::server::connector (
  $catalina_base         = $::tomcat::catalina_base,
  $connector_ensure      = 'present',
  $protocol              = undef,
  $port,
  $parent_service        = 'Catalina',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  validate_re($connector_ensure, '^(present|absent|true|false)$')

  if $protocol {
    $_protocol = $protocol
  } else {
    $_protocol = $name
  }

  $base_path = "Server/Service[#attribute/name='${parent_service}']/Connector[#attribute/protocol='${_protocol}']"

  if $connector_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
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

  if ! empty($changes) {
    augeas { "server-${catalina_base}-${parent_service}-connector-${_protocol}":
      lens    => 'Xml.lns',
      incl    => "${catalina_base}/conf/server.xml",
      changes => $changes,
    }
  }
}
