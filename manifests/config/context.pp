# Definition: tomcat::config::context
#
# Configure attributes for the Context element in $CATALINA_BASE/conf/context.xml
#
# Parameters
# - $catalina_base is the base directory for the Tomcat installation.



define tomcat::config::context (
  $catalina_base = $::tomcat::catalina_home,
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
