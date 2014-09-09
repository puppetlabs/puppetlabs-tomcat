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
define tomcat::config::context::resource (
  $auth,
  $type,
  $driverClassName,
  $username,
  $password,
  $maxActive,
  $maxIdle,
  $maxWait,
  $url,
  $factory,
  $catalina_base   = $::tomcat::catalina_home,
  $resource_ensure = 'present',
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($resource_ensure, '^(present|absent|true|false)$')

  $base_path = 'Context/Resource'

  if $resource_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_name            = "set ${base_path}/#attribute/name ${name}"
    $_auth            = "set ${base_path}/#attribute/auth ${auth}"
    $_type            = "set ${base_path}/#attribute/type ${type}"
    $_driverClassName =
      "set ${base_path}/#attribute/driverClassName ${driverClassName}"
    $_username        = "set ${base_path}/#attribute/username ${username}"
    $_password        = "set ${base_path}/#attribute/password ${password}"
    $_maxActive       = "set ${base_path}/#attribute/maxActive ${maxActive}"
    $_maxIdle         = "set ${base_path}/#attribute/maxIdle ${maxIdle}"
    $_maxWait         = "set ${base_path}/#attribute/maxWait ${maxWait}"
    $_url             = "set ${base_path}/#attribute/url ${url}"
    $_factory         = "set ${base_path}/#attribute/factory ${factory}"

    $changes = delete_undef_values([$_name, $_auth, $_type,
                                    $_driverClassName, $_username, $_password,
                                    $_maxActive, $_maxIdle, $_maxWait, $_url,
                                    $_factory ])
  }

  augeas { "context-${catalina_base}-resource-${_connection_name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
