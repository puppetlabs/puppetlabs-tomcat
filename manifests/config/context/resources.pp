# @summary Configure Resources elements in $CATALINA_BASE/conf/context.xml
#
# @param ensure
#   Specifies whether you are trying to add or remove the Resources element.
# @param resources_name
#   The name of the Resources to be created, relative to the `java:comp/env` context. `$name`.
# @param name
#   `$resources_name`
# @param resources_type
#   The fully qualified Java class name expected by the web application when it performs a lookup for this resources. Required to create the resource.
# @param catalina_base
#   Specifies the root of the Tomcat installation.
# @param additional_attributes
#   Specifies any additional attributes to add to the Valve. Should be a hash of the format 'attribute' => 'value'. Optional
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::resources (
  Enum['present','absent'] $ensure = 'present',
  $resources_name                  = $name,
  $resources_type                  = undef,
  $catalina_base                   = $::tomcat::catalina_home,
  Hash $additional_attributes      = {},
  Array $attributes_to_remove      = [],
  Boolean $show_diff               = true,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $resources_name {
    $_resources_name = $resources_name
  } else {
    $_resources_name = $name
  }

  $base_path = "Context/Resources[#attribute/name='${_resources_name}']"

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    # (MODULES-3353) does this need to be quoted?
    $set_name = "set ${base_path}/#attribute/name ${_resources_name}"
    if $resources_type {
      $set_type = "set ${base_path}/#attribute/type ${resources_type}"
    } else {
      $set_type = undef
    }

    if ! empty($additional_attributes) {
      $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $rm_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
          $set_name,
          $set_type,
          $set_additional_attributes,
          $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-resources-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $changes,
    show_diff => $show_diff,
  }
}
