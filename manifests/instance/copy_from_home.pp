# Definition: tomcat::instance::copy_from_home
#
# Private define to copy a conf file from catalina_home to catalina_base
#
define tomcat::instance::copy_from_home (
  $catalina_home,
  $user          = $::tomcat::user,
  $group         = $::tomcat::group,
) {
  $filename = basename($name)

  file { $name:
    ensure  => file,
    mode    => '0660',
    owner   => $user,
    group   => $group,
    source  => "${catalina_home}/conf/${filename}",
    replace => false,
  }
}
