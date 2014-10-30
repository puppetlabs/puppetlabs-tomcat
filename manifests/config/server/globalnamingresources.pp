# Definition: tomcat::config::server::globalnamingresources
#
# Configure Resource elements in $CATALINA_BASE/conf/server.xml
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
define tomcat::config::server::globalnamingresources (
  $resource_name,
  $auth,
  $type,
  $factory,
  $description     = undef,
  $driverClassName = undef,
  $maxActive       = undef,
  $maxIdle         = undef,
  $maxWait         = undef,
  $username        = undef,
  $url             = undef,
  $password        = undef,
  $pathname        = undef,
  $catalina_base   = $::tomcat::catalina_home,
  $resource_ensure = 'present',
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($resource_ensure, '^(present|absent|true|false)$')

  $base_path = 'Server/GlobalNamingResources/Resource'

  if $resource_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_resource_name   = "set ${base_path}/#attribute/name ${resource_name}"
    $_auth            = "set ${base_path}/#attribute/auth ${auth}"
    $_type            = "set ${base_path}/#attribute/type ${type}"
    $_url             = "set ${base_path}/#attribute/url ${url}"
    $_factory         = "set ${base_path}/#attribute/factory ${factory}"

    if $description {
      $_description = "set ${base_path}/#attribute/description ${description}"
    }
    else {
      $_description = undef
    }

    if $url {
      $_url = "set ${base_path}/#attribute/url ${url}"
    }
    else {
      $_url = undef
    }

    if $maxActive {
      $_maxActive = "set ${base_path}/#attribute/maxActive ${maxActive}"
    }
    else {
      $_maxActive = undef
    }

    if $maxIdle {
      $_maxIdle = "set ${base_path}/#attribute/maxIdle ${maxIdle}"
    }
    else {
      $_maxIdle = undef
    }

    if $maxWait {
      $_maxWait = "set ${base_path}/#attribute/maxWait ${maxWait}"
    }
    else {
      $_maxWait = undef
    }

    if $username {
      $_username = "set ${base_path}/#attribute/username ${username}"
    }
    else {
      $_username = undef
    }

    if $password {
      $_password = "set ${base_path}/#attribute/password ${password}"
    }
    else {
      $_password = undef
    }

    if $pathname {
      $_pathname = "set ${base_path}/#attribute/pathname ${pathname}"
    }
    else {
      $_pathname = undef
    }

    if $driverClassName {
      $_driverClassName = "set ${base_path}/#attribute/driverClassName ${driverClassName}"
    }
    else {
      $_driverClassName = undef
    }

    $changes = delete_undef_values([$_resource_name, $_auth, $_type,
                                    $_driverClassName, $_username, $_password,
                                    $_maxActive, $_maxIdle, $_maxWait, $_url,
                                    $_factory, $_pathname, $_description ])
  }

  augeas { "server-${catalina_base}-globaalnamingresources-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/server.xml",
    changes => $changes,
  }
}
