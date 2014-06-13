define tomcat::config::server::service (
  $catalina_base     = $::tomcat::catalina_home,
  $class_name        = undef,
  $class_name_ensure = 'present',
  $service_ensure    = 'present',
) {
  validate_re($service_ensure, '^(present|absent|true|false)$')
  validate_re($class_name_ensure, '^(present|absent|true|false)$')

  if $service_ensure =~ /^(absent|false)$/ {
    $changes = "rm Server/Service[#attribute/name='${name}']"
  } else {
    if $class_name_ensure =~ /^(absent|false)$/ {
      $_class_name = "rm Server/Service[#attribute/name='${name}']/#attribute/className"
    } elsif $class_name {
      $_class_name = "set Server/Service[#attribute/name='${name}']/#attribute/className ${class_name}"
    }
    $_service = "set Server/Service[#attribute/name='${name}']/#attribute/name ${name}"
    $changes = delete_undef_values([$_class_name, $_service])
  }

  if ! empty($changes) {
    augeas { "server-${catalina_base}-service-${name}":
      lens    => 'Xml.lns',
      incl    => "${catalina_base}/conf/server.xml",
      changes => $changes,
    }
  }
}
