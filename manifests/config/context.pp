# @summary Configure attributes for the Context element in $CATALINA_BASE/conf/context.xml
#
# @param catalina_base
#   Specifies the root of the Tomcat installation.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context (
  $catalina_base     = undef,
  Boolean $show_diff = true,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $_watched_resource = 'set Context/WatchedResource/#text "WEB-INF/web.xml"'

  $changes = delete_undef_values([$_watched_resource])

  if ! empty($changes) {
    augeas { "context-${_catalina_base}":
      lens      => 'Xml.lns',
      incl      => "${_catalina_base}/conf/context.xml",
      changes   => $changes,
      show_diff => $show_diff,
    }
  }
}
