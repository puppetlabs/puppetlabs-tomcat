# Definition: tomcat::config::server::listener
#
# Configure Listener elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $listener_ensure specifies whether you are trying to add or remove the
#   Listener element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $class_name is the Java class name of the implementation to use.
#   Defaults to $name.
# - Optional $parent_server_port is the port of the Server element this
#   Listener should be nested beneath.
# - An optional hash of $additional_attributes to add to the Listener. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Listener.
# 

define tomcat::config::server::listener (
  $catalina_base         = $::tomcat::catalina_home,
  $listener_ensure       = 'present',
  $class_name            = undef,
  $parent_server_port    = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  
  # Dependencies:
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }
  
  # Parameters Validation:
  validate_re($listener_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)
  if $parent_server_port and ! is_integer($parent_server_port) {
    fail('Parameter $parent_server_port is not an Integer')
  }
  
  # Default Parameters:
  if $class_name {
    $_class_name = $class_name
  } else {
    $_class_name = $name
  }
  
  if $parent_server_port {
    $path = "Server[#attribute/port='${parent_server_port}']/Listener[#attribute/className='${_class_name}']"
  } else {
    $path = "Server/Listener[#attribute/className='${_class_name}']"
  }
  
  if $listener_ensure =~ /^(absent|false)$/ {
    # Remove the Listener - changes for augeas:
    $augeaschanges = "rm ${path}"
  } elsif $listener_ensure =~ /^(present|true)$/ {
    $listener = "set ${path}/#attribute/className ${_class_name}"
    # Add additional_attributes when needed:  
    if ! empty($additional_attributes) {
      $_additional_attributes = prefix(join_keys_to_values($additional_attributes, ' '), "set ${path}/#attribute/")
    } else {
      $_additional_attributes = undef
    }
    # Remove attributes when needed:
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }
    # Changes for augeas:
    $augeaschanges = delete_undef_values(flatten([$listener, $_additional_attributes, $_attributes_to_remove]))
  }
  
  augeas { "server-${catalina_base}-listener-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/server.xml",
    changes => $augeaschanges,
  }
}
