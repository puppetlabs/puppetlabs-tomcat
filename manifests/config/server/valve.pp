# Definition tomcat::config::server::valve
#
# Configure a Valve element in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# @param catalina_base is the root of the Tomcat installation
# @param class_name is the className attribute. If not specified, defaults to $name.
# @param parent_host is the Host element this Valve should be nested beneath. If not
#        specified, the Valve will be nested beneath the Engine under
#        $parent_service.
# @param parent_context is the Context element this Valve should be nested beneath 
#        under the host element. If not specified, the Valve will be nested beneath
#        the parent host
# @param parent_service is the Service element this Valve should be nested beneath.
#        Defaults to 'Catalina'.
# @param valve_ensure specifies whether you are trying to add or remove the Vavle
#        element. Valid values are 'present' or 'absent'. Defaults to 'present'.
# @param additional_attributes An optional hash of additional attributes to add to the Valve. Should be of
#        the format 'attribute' => 'value'.
# @param attributes_to_remove An optional array of attributes to remove from the Valve.
# @param server_config Specifies a server.xml file to manage.
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
