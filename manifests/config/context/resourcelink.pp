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
define tomcat::config::context::resourcelink (
  $global,
  $resource_link_name,
  $type,
  $catalina_base   = $::tomcat::catalina_home,
  $resource_ensure = 'present',
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($resource_ensure, '^(present|absent|true|false)$')

  $base_path = 'Context/ResourceLink'

  if $resource_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_resource_link_name = "set ${base_path}/#attribute/name ${resource_name}"
    $_global             = "set ${base_path}/#attribute/global ${global}"
    $_type               = "set ${base_path}/#attribute/type ${type}"

    $changes = delete_undef_values([$_resource_link_name, $_type, $_global ])
  }

  augeas { "context-${catalina_base}-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
