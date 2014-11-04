# Definition: tomcat::config::server::listener
#
# Configure Listener elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $listener_ensure specifies whether you are trying to add or remove the
#   Listener element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $class_name is the Java class name of the implementation to use and
#   is required.
# - An optional hash of $additional_attributes to add to the Listener. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Listener.
# 

define tomcat::config::server::listener (
  $catalina_base         = $::tomcat::catalina_home,
  $listener_ensure       = 'present',
  $class_name             = undef,
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
  
  # Mandatory Parameters:
  if ! $class_name {
    fail( '$class_name must be specified.' )
  }

  # According to the tomcat doc, possible values: Server|Engine|Host|Context
  $parent_element = 'Server'
  $base_path = "${parent_element}"
  $path = "${base_path}/Listener[#attribute/class_name='${class_name}']"
  
  if $listener_ensure =~ /^(absent|false)$/ {
    # Remove the Listener - changes for augeas:
    $augeaschanges = "rm ${path}"
  } elsif $listener_ensure =~ /^(present|true)$/ {
    $_class_name = "set ${path}/#attribute/class_name ${class_name}"
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
    $augeaschanges = delete_undef_values(flatten([$_class_name, $_additional_attributes, $_attributes_to_remove]))
  }
  
  augeas { "server-${catalina_base}-listener-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/server.xml",
    changes => $augeaschanges,
  }
}
