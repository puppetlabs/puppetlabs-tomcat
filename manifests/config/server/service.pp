# Definition: tomcat::config::server::service
#
# Configure a Service element nested in the Server element in
# $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $service_name is the name of the Service to be created.
#   Defaults to `$name`.
# - $catalina_base is the root of the Tomcat installation.
# - $class_name is the optional className attribute
# - $class_name_ensure specifies whether you are trying to set or remove the
#   className attribute. Valid values are 'true', 'false', 'present', or
#   'absent'. Defaults to 'absent'.
# - $service_ensure specifies whether you are trying to add or remove the
#   service element. Valid values are 'true', 'false', 'present', or 'absent'.
#   Defaults to 'present'.
define tomcat::config::server::service (
  $service_name      = $name,
  $catalina_base     = undef,
  $class_name        = undef,
  $class_name_ensure = 'absent',
  $service_ensure    = 'present',
  $server_config     = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_string($service_name)
  validate_re($service_ensure, '^(present|absent|true|false)$')
  validate_re($class_name_ensure, '^(present|absent|true|false)$')

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $service_ensure =~ /^(absent|false)$/ {
    $changes = "rm Server/Service[#attribute/name='${service_name}']"
  } else {
    if $class_name_ensure =~ /^(present|true)$/ {
      if empty($class_name) {
        fail('$class_name must be specified when $class_name_ensure is set to true or present')
      }
      $_class_name = "set Server/Service[#attribute/name='${service_name}']/#attribute/className ${class_name}"
    } else {
      $_class_name = "rm Server/Service[#attribute/name='${service_name}']/#attribute/className"
    }
    $_service = "set Server/Service[#attribute/name='${service_name}']/#attribute/name ${service_name}"
    $changes = delete_undef_values([$_service, $_class_name])
  }

  if ! empty($changes) {
    augeas { "server-${_catalina_base}-service-${service_name}":
      lens    => 'Xml.lns',
      incl    => $_server_config,
      changes => $changes,
    }
  }
}
