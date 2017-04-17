# Definition: tomcat::config::context::parameter
#
# Configure parameter elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $ensure specifies whether you are trying to add or remove the
#   parameter element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $catalina_base is the base directory for the Tomcat installation.
# - $parameter_name is the name of the parameter to be created, relative to
#   the java:comp/env context.
# - $type is the fully qualified Java class name expected by the web application
#   for this parameter entry.
# - $value that will be presented to the container.
# - $description is an optional string for a human-readable description
#   of this parameter entry.
# - Set $override to false if you do not want a <parameter> for
#   the same parameter entry name to override the value specified here.
define tomcat::config::context::parameter (
  Optional[String]                            $value = undef,
  Variant[Enum['present', 'absent'], Boolean] $ensure        = 'present',
  Pattern[/^(\/[^\/ ]*)+\/?$/]                $catalina_base  = $::tomcat::catalina_home,
  String                                      $parameter_name = $name,
  Optional[String]                            $description    = undef,
  Optional[Boolean]                           $override       = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $base_path = "Context/Parameter[#attribute/name='${parameter_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  }
  else {

    if empty($value) {
      fail('$value must be specified')
    }

    $set_name  = "set ${base_path}/#attribute/name ${parameter_name}"
    $set_value = "set ${base_path}/#attribute/value ${value}"

    if type($override) == Boolean {
      $set_override = "set ${base_path}/#attribute/override ${override}"
    } else {
      $set_override = "rm ${base_path}/#attribute/override"
    }

    if ! empty($description) {
      $set_description = "set ${base_path}/#attribute/description \'${description}\'"
    } else {
      $set_description = "rm ${base_path}/#attribute/description"
    }

    $changes = delete_undef_values(flatten([
      $set_name,
      $set_value,
      $set_override,
      $set_description,
    ]))
  }

  augeas { "context-${catalina_base}-parameter-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
