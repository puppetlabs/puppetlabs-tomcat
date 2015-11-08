# Definition: tomcat::instance::conf_copy_from_home
#
# Private define to copy a conf file from catalina_home to catalina_base
#
define tomcat::instance::conf_copy_from_home (
  $catalina_base,
  $catalina_home,
  $replace       = false,
  $user          = $::tomcat::user,
  $group         = $::tomcat::group,
) {
  file { "${catalina_base}/conf/${title}":
    mode    => '0660',
    source  => "${catalina_home}/conf/${title}",
    require => File["${catalina_base}/conf"],
    replace => $replace,
  }
}
