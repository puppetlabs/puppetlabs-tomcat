# Definition: tomcat::config::server
#
# Configure attributes for the Server element in $CATALINA_BASE/conf/server.xml
#
# Parameters
# - $catalina_base is the base directory for the Tomcat installation.
# - $class_name is the optional className attribute.
# - $class_name_ensure specifies whether you are trying to set or remove the
#   className attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'present'.
# - $address is the optional address attribute.
# - $address_ensure specifies whether you are trying to set of remove the
#   address attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'present'.
# - The $port to wait for shutdown commands on.
# - The $shutdown command that must be sent to $port.
define tomcat::config::context (
  $catalina_base           = $::tomcat::catalina_home,
  $class_name              = undef,
  $class_name_ensure       = 'present',
  $address                 = undef,
  $address_ensure          = 'present',
  $port                    = undef,
  $shutdown                = undef,
) {

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $_watched_resource = 'set Context/WatchedResource/#text "WEB-INF/web.xml"'

  $changes = delete_undef_values([$_watched_resource])

  if ! empty($changes) {
    augeas { "context-${catalina_base}":
      lens    => 'Xml.lns',
      incl    => "${catalina_base}/conf/context.xml",
      changes => $changes,
    }
  }
}
