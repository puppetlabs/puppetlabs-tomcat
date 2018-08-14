# @summary Configure a Valve element in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path. `$::tomcat::catalina_home`.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging/Attributes). Valid options: a string containing a Java class name.
# @param parent_host
#   Specifies which virtual host the Valve should nest under. Valid options: a string containing the name of a Host element.
# @param parent_service
#   Specifies which Service element the Valve should nest under. Valid options: a string containing the name of a Service element.
# @param parent_context
#   Specifies which Context element the Valve should nest under. Valid options: a string containing the name of a Context element (matching the docbase attribute).
# @param valve_ensure
#   Specifies whether the Valve should exist in the configuration file. Maps to the  [Valve XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Introduction).
# @param additional_attributes
#   Specifies any further attributes to add to the Valve. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
#
define tomcat::config::server::valve (
  $catalina_base                         = undef,
  $class_name                            = undef,
  $parent_host                           = undef,
  $parent_service                        = 'Catalina',
  $parent_context                        = undef,
  Enum['present','absent'] $valve_ensure = 'present',
  Hash $additional_attributes            = {},
  Array $attributes_to_remove            = [],
  $server_config                         = undef,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $class_name {
    $_class_name = $class_name
  } else {
    $_class_name = $name
  }

  # lint:ignore:140chars
  if $parent_host {
    if $parent_context {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${parent_context}']/Valve[#attribute/className='${_class_name}']"
    } else {
      $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Valve[#attribute/className='${_class_name}']"
    }
  } else {
    $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Valve[#attribute/className='${_class_name}']"
  }
  # lint:endignore

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $valve_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $_class_name_change = "set ${base_path}/#attribute/className ${_class_name}"
    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([$_class_name_change, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_host}-valve-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
