# Definition: tomcat::config::server::realm
#
# Configure Realm elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# @param catalina_base is the base directory for the Tomcat installation.
# @param class_name is the Java class name of the Realm implementation to use.
# @param realm_ensure specifies whether you are adding or removing a
#        Realm element. Valid values are 'present', and 'absent'. Defaults to 'present'.
# @param parent_service is the `name` attribute for the Service element this Realm
#        should be nested beneath. Defaults to 'Catalina'.
# @param parent_engine is the `name` attribute for the Engine element this Realm
#        should be nested beneath. Defaults to 'Catalina'.
# @param parent_host is the `name` attribute for the Host element this Realm
#        should be nested beneath.
# @param parent_realm is the `name` attribute for the Realm element this Realm
#        should be nested beneath.
# @param additional_attributes An optional hash of additional attributes to add to the Realm.
#        Should be of the format 'attribute' => 'value'.
# @param attributes_to_remove An optional array of attributes to remove from the Realm.
# @param purge_realms Specifies whether to purge any unmanaged realm elements
#        from the configuration file by default.
# @param server_config Specifies a server.xml file to manage.
define tomcat::config::server::realm (
  $catalina_base                                          = undef,
  $class_name                                             = $name,
  Variant[Enum['present','absent'],Boolean] $realm_ensure = 'present',
  $parent_service                                         = 'Catalina',
  $parent_engine                                          = 'Catalina',
  $parent_host                                            = undef,
  $parent_realm                                           = undef,
  Hash $additional_attributes                             = {},
  Array $attributes_to_remove                             = [],
  Optional[Boolean] $purge_realms                         = undef,
  $server_config                                          = undef,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))
  $_purge_realms = pick($purge_realms, $::tomcat::purge_realms)

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $_purge_realms and ($realm_ensure =~ /^(absent|false)$/) {
    fail('$realm_ensure must be set to \'present\' to use $purge_realms')
  }

  if $_purge_realms {
    # Perform deletions in reverse depth order as workaround for
    # https://github.com/hercules-team/augeas/issues/319
    $__purge_realms = [
      'rm //Realm//Realm',
      'rm //Context//Realm',
      'rm //Host//Realm',
      'rm //Engine//Realm',
      'rm //Server//Realm',
    ]
  } else {
    $__purge_realms = undef
  }

  $engine_path = "Server/Service[#attribute/name='${parent_service}']/Engine[#attribute/name='${parent_engine}']"

  # The Realm may be nested under a Host element.
  if $parent_host {
    $host_path = "${engine_path}/Host[#attribute/name='${parent_host}']"
  } else {
    $host_path = $engine_path
  }

  # The Realm could also be nested under another Realm element if the parent realm is a CombinedRealm.
  if $parent_realm {
    $path = "${host_path}/Realm[#attribute/className='${parent_realm}']/Realm"
  } else {
    $path = "${host_path}/Realm"
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  # For backwards-compatible reasons, match previously managed realms that do
  # not have puppetName but have a known className. Either we match puppetName
  # or className; puppet could not have created a state in which two realms
  # match.
  $path_expression = "#attribute/puppetName='${name}' or (count(#attribute/puppetName)=0 and #attribute/className='${class_name}')"

  if $realm_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${path}[${path_expression}]"
  } else {

    # This will create the node if there are no matches
    $_class_name = "set ${path}[${path_expression}]/#attribute/className ${class_name}"
    $puppet_name = "set ${path}[${path_expression}]/#attribute/puppetName ${name}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"),
                                              "set ${path}[${path_expression}]/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}[${path_expression}]/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
      $__purge_realms,
      $puppet_name,
      $_class_name,
      $_additional_attributes,
      $_attributes_to_remove ]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_engine}-${parent_host}-${parent_realm}-realm-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }

}
