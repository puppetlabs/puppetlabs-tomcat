# Definition: tomcat::config::context
#
# Configure attributes for the Context element in $CATALINA_BASE/conf/context.xml
#
# Parameters
# @param catalina_base is the base directory for the Tomcat installation.
# @param resouces_attributes configures global resource settings
# @param resouces_remove_attributes configures global resource settings to remove



define tomcat::config::context (
  $catalina_base = undef,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $_watched_resource = 'set Context/WatchedResource/#text "WEB-INF/web.xml"'

  # Global resource settings
  $resources_base_path = 'Context/Resources'
  if empty($resources_attributes) {
    $rm_resources = "rm ${resources_base_path}"

    $changes = delete_undef_values(flatten([
      $_watched_resource,
      $rm_resources,
    ]))
  } else {
    $set_resources_attributes = suffix(prefix(join_keys_to_values($resources_attributes, " '"),
        "set ${resources_base_path}/#attribute/"), "'")

    if !empty(any2array($resources_remove_attributes)) {
      $rm_resources_attributes =
        prefix(any2array($resources_remove_attributes), "rm ${resources_base_path}/#attribute/")
    } else {
      $rm_resources_attributes = undef
    }

    $changes = delete_undef_values(flatten([
      $_watched_resource,
      $set_resources_attributes,
      $rm_resources_attributes,
    ]))
  }

  if ! empty($changes) {
    augeas { "context-${_catalina_base}":
      lens    => 'Xml.lns',
      incl    => "${_catalina_base}/conf/context.xml",
      changes => $changes,
    }
  }
}
