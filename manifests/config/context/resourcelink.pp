# Definition tomcat::config::context::resourcelink
#
# Configure a ResourceLink element in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the root of the Tomcat installation
# - $resourceLink_ensure specifies whether you are trying to add or remove the resourceLink
#   element. Valid values are 'true', 'false', 'present', or 'absent'. Defaults
#   to 'present'.
# - An optional hash of $additional_attributes to add to the Context. Should be of
#   the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Context.
#
define tomcat::config::context::resourcelink (
  $catalina_base         = $::tomcat::catalina_home,
  $context_ensure        = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $context_config         = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Context configurations require Augeas >= 1.0.0')
  }

  validate_re($context_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)

  if $context_config {
    $_context_config = $server_config
  } else {
    $_context_config = "${catalina_base}/conf/context.xml"
  }

  $path = "Context/ResourceLink[#attribute/name='${name}']"
  if $context_ensure =~ /^(absent|false)$/ {
    $augeaschanges = "rm ${path}"
  } else {
    $context = "set ${path}/#attribute/name ${name}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }

    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $augeaschanges = delete_undef_values(flatten([$context, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${catalina_base}-${_parent_service}-${_parent_engine}-${parent_host}-context-${name}":
    lens    => 'Xml.lns',
    incl    => $_context_config,
    changes => $augeaschanges,
  }
}
