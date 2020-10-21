# @summary Configure Executor elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param executor_name
#   The name of the executor element.
# @param ensure
#   Specifies whether the executor ([The Executor Component](https://tomcat.apache.org/tomcat-8.0-doc/config/executor.html)) should exist in the configuration file.
# @param parent_service
#   Specifies which Service element the Listener should nest under. Only valid if `parent_engine` or `parent_host` is specified. Valid options: a string containing the name attribute of the Service.
# @param additional_attributes
#   Specifies any further attributes to add to the Host. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::executor(
  Optional[String] $catalina_base     = undef,
  Optional[String] $executor_name     = undef,
  Optional[String] $parent_service    = 'Catalina',
  Enum['present','absent'] $ensure    = 'present',
  Hash $additional_attributes         = {},
  Array[String] $attributes_to_remove = [],
  Boolean $show_diff                  = true,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $executor_name {
    $_executor_name = $executor_name
  } else {
    $_executor_name = $name
  }

  $path = "Server/Service[#attribute/name='${parent_service}']/Executor[#attribute/name='${_executor_name}']"

  if $ensure == 'absent' {
    $augeaschanges = "rm ${path}"
  } else {
    $set_name = "set ${path}/#attribute/name ${_executor_name}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }

    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $augeaschanges = delete_undef_values(flatten([
      $set_name,
      $_additional_attributes,
      $_attributes_to_remove,
    ]))
  }

  augeas { "server-${catalina_base}-executor-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/server.xml",
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
