# @summary Specifies Valve elements in `${catalina_base}/conf/context.xml`
#
# @param ensure
#   Specifies whether you are trying to add or remove the Valve element.
# @param resource_type
#   The fully qualified Java class name expected by the web application when it performs a lookup for this resource.
#   Required to create the resource. Default: `$name`
# @param catalina_base
#   Specifies the root of the Tomcat installation. Default: `$tomcat::catalina_home`
# @param additional_attributes
#   Specifies any further attributes to add to the Valve. Valid options: a hash of '< attribute >' => '< value >' pairs. `{}`.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::valve (
  Enum['present','absent'] $ensure = 'present',
  $resource_type                   = $name,
  $catalina_base                   = $::tomcat::catalina_home,
  Hash $additional_attributes      = {},
  Array $attributes_to_remove      = [],
  Boolean $show_diff               = true,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $base_path = "Context/Valve[#attribute/className='${resource_type}']"

  if $ensure == 'absent' {
    $changes = "rm ${base_path}"
  } else {
    $set_type = "set ${base_path}/#attribute/className ${resource_type}"

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
      $set_type,
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-valve-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $changes,
    show_diff => $show_diff,
  }
}
