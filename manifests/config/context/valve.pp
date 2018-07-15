# @summary Specifies Valve elements in `${catalina_base}/conf/context.xml`
#
# @param ensure
#   Specifies whether you are trying to add or remove the Valve element.
# @param resource_name
#   The name of the Resource to be created, relative to the java:comp/env context. Default: `$name`
# @param name
#   `$resource_name`
# @param resource_type
#   The fully qualified Java class name expected by the web application when it performs a lookup for this resource. Required to create the resource.
# @param catalina_base
#   Specifies the root of the Tomcat installation. Default: `$tomcat::catalina_home`
# @param additional_attributes
#   Specifies any further attributes to add to the Valve. Valid options: a hash of '< attribute >' => '< value >' pairs. `{}`.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
#
define tomcat::config::context::valve (
  Enum['present','absent'] $ensure = 'present',
  $resource_name                   = $name,
  $resource_type                   = undef,
  $catalina_base                   = $::tomcat::catalina_home,
  Hash $additional_attributes      = {},
  Array $attributes_to_remove      = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $resource_name {
    $_resource_name = $resource_name
  } else {
    $_resource_name = $name
  }

  $base_path = "Context/Valve[#attribute/name='${_resource_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    # (MODULES-3353) does this need to be quoted?
    $set_name = "set ${base_path}/#attribute/name ${_resource_name}"
    if $resource_type {
      $set_type = "set ${base_path}/#attribute/className ${resource_type}"
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

  augeas { "context-${catalina_base}-valve-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
