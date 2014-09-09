# Definition: tomcat::config::server::resourcelink
#
# Configure a ResourceLink element in the designated xml config.
#
# Parameters:
# - $ensure specifies whether you are trying to add or remove the
#   ResourceLink element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $catalina_base is the root of the Tomcat installation
# - $catalina_base is the base directory for the Tomcat installation.
# - $resourcelink_name The name of the resource link to be created, relative
#   to the java:comp/env context. Defaults to $name
# - $resourcelink_global The name of the linked global resource in the global JNDI context. Optional, defaults to undef
# - $resourcelink_type The fully qualified Java class name expected by the web
#   application when it performs a lookup for this resource link. Optional,
#   defaults to undef
# - $context_xml is the xml configuration file for the ResourceLink configuration. Default: $catalina_base/conf/context.xml
define tomcat::config::context::resourcelink (
  $ensure              = 'present',
  $catalina_base       = $::tomcat::catalina_home,
  $resourcelink_name   = undef,
  $resourcelink_global = undef,
  $resourcelink_type   = undef,
  $context_xml         = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Context configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  if $resourcelink_name {
    $_resourcelink_name = $resourcelink_name
  } else {
    $_resourcelink_name = $name
  }

  if $context_xml {
    $_context_xml = $context_xml
  } else {
    $_context_xml = "${catalina_base}/conf/context.xml"
  }

  $base_path = "Context/ResourceLink[#attribute/name='${_resourcelink_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $augeaschanges = "rm ${base_path}"
  } else {
    $set_name = "set ${base_path}/#attribute/name ${_resourcelink_name}"

    if $resourcelink_global {
      $set_global = "set ${base_path}/#attribute/global ${resourcelink_global}"
    } else {
      $set_global = undef
    }
    if $resourcelink_type {
      $set_type = "set ${base_path}/#attribute/type ${resourcelink_type}"
    } else {
      $set_type = undef
    }

    $augeaschanges = delete_undef_values(flatten([
      $set_name,
      $set_global,
      $set_type,
    ]))
  }

  augeas { "${catalina_base}-context-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => $_context_xml,
    changes => $augeaschanges,
  }
}
