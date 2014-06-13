#
#
define tomcat::config::server (
  $catalina_base           = $::tomcat::catalina_home,
  $class_name              = undef,
  $class_name_ensure       = 'present',
  $address                 = undef,
  $address_ensure          = 'present',
  $port                    = undef,
  $shutdown                = undef,
) {

  validate_re($class_name_ensure, '^(present|absent|true|false)$')
  validate_re($address_ensure, '^(present|absent|true|false)$')

  if $class_name_ensure =~ /^(absent|false)$/ {
    $_class_name = "rm Server/#attribute/className"
  } elsif $class_name {
    $_class_name = "set Server/#attribute/className ${class_name}"
  }
  if $address =~ /^(absent|false)$/ {
    $_address = "rm Server/#attribute/address"
  } elsif $address {
    $_address = "set Server/#attribute/address ${address}"
  }

  if $port {
    $_port = "set Server/#attribute/port ${port}"
  }

  if $shutdown {
    $_shutdown = "set Server/#attribute/shutdown ${shutdown}"
  }

  $changes = delete_undef_values([$_class_name, $_address, $_port, $_shutdown])

  if ! empty($changes) {
    augeas { "server-${catalina_base}":
      lens    => 'Xml.lns',
      incl    => "${catalina_base}/conf/server.xml",
      changes => $changes,
    }
  }
}
