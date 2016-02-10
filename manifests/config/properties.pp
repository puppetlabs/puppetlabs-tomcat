## manage the catalina.properties file
# private
define tomcat::config::properties (
  $catalina_base,
  $catalina_home,
  $user,
  $group,
) {
  concat { "${catalina_base}/conf/catalina.properties":
    ensure         => present,
    ensure_newline => true,
    owner          => $user,
    group          => $group,
    mode           => '0640',
  }
  concat::fragment { "${catalina_base} properties base file from catalina_home ${$catalina_home}/conf/catalina.properties":
    target => "${catalina_base}/conf/catalina.properties",
    source => "${catalina_home}/conf/catalina.properties",
    order  => '01',
  }
}
