# Definition: tomcat::config::context::resource
#
# Configure Resource elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $ensure specifies whether you are trying to add or remove the
#   Resource element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $resource_name is the name of the Resource to be created, relative to 
#   the java:comp/env context.
# - $auth authentication type for the Resource
# - $type is the fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource
# - $close_method Name of the zero-argument method to call on a singleton 
#   resource when it is no longer required.
# - $description Optional, human-readable description of this resource.
# - $scope Specify whether connections obtained through this resource 
#   manager can be shared. [Shareable|Unshareable]
# - $singleton Specify whether this resource definition is for a singleton 
#   resource [true|false]
#   $type The fully qualified Java class name expected by the web application 
#   when it performs a lookup for this resource.
# - An optional hash of $additional_attributes to add to the Resource. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Connector.
define tomcat::config::context::resource (
  $resource_name         = undef,
  $auth                  = undef,
  $close_method          = undef,
  $description           = undef,
  $scope                 = undef,
  $singleton             = undef,
  $type                  = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $ensure                = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  
  if $resource_name {
    $_resource_name = $resource_name
  } else {
    $_resource_name = $name
  }

  $base_path = "Context/Resource[#attribute/name='${_resource_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    
    $_resource   = "set ${base_path}/#attribute/name ${_resource_name}"
    
    if $auth {
      $_auth = "set ${base_path}/#attribute/auth ${auth}"
    } else {
      $_auth = undef
    }
    
    if $close_method {
      $_close_method = "set ${base_path}/#attribute/closeMethod ${close_method}"
    } else {
      $_close_method = undef
    }
    
    if $description {
      $_description = "set ${base_path}/#attribute/description ${description}"
    } else {
      $_description = undef
    }
    
    if $scope {
      $_scope = "set ${base_path}/#attribute/scope ${scope}"
    } else {
      $_scope = undef
    }
    
    if $singleton {
      $_singleton = "set ${base_path}/#attribute/singleton ${singleton}"
    } else {
      $_singleton = undef
    }
    
    if $type {
      $_type = "set ${base_path}/#attribute/type ${type}"
    } else {
      $_type = undef
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

                                    
    $changes = delete_undef_values(flatten([$_resource, $_auth, $_close_method,
                                            $_description, $_scope, $_singleton,
                                            $_type, $_additional_attributes,
                                            $_attributes_to_remove]))
  }

  augeas { "context-${catalina_base}-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
