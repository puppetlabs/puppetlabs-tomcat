# Definition: tomcat::config::server::resourcelink
#
# Configure ResourceLink elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $ensure specifies whether you are trying to add or remove the
#   ResourceLink element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $global The name of the linked global resource in the global JNDI context.
# - $resource_type The fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource link.
# - $resource_link_name The name of the resource link to be created, relative 
#   to the java:comp/env context.
# - An optional hash of $additional_attributes to add to the Connector. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::context::resourcelink (
  $resource_link_name    = undef,
  $global                = undef,
  $resource_type         = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $ensure                = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  
  if $resource_link_name {
    $_resource_link_name = $resource_link_name
  } else {
    $_resource_link_name = $name
  }

  $base_path = "Context/ResourceLink[#attribute/name='${_resource_link_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    
    $_resource_link = "set ${base_path}/#attribute/name ${_resource_link_name}"
    
    if $global {
      $_global = "set ${base_path}/#attribute/global ${global}"
    } else {
      $_global = undef
    }
    
    if $resource_type {
      $_resource_type = "set ${base_path}/#attribute/type ${resource_type}"
    } else {
      $_resource_type = undef
    }

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

    $changes = delete_undef_values(flatten([$_resource_link, $_resource_type,
                                            $_global, $_additional_attributes,
                                            $_attributes_to_remove]))
  }

  augeas { "context-${catalina_base}-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
