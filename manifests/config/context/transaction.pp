# @summary Configure Transaction elements in $CATALINA_BASE/conf/context.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param transaction_name
#   The name of the transaciton.
# @param factory
#   The class name for the JNDI object factory.
# @param ensure
#   Specifies whether the transaction element should exist in the configuration file.
# @param additional_attributes
#   Specifies any further attributes to add to the Host. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context::transaction(
  Optional[String] $catalina_base     = undef,
  Optional[String] $transaction_name  = undef,
  String $factory                     = undef,
  Enum['present','absent'] $ensure    = 'present',
  Hash $additional_attributes         = {},
  Array[String] $attributes_to_remove = [],
  Boolean $show_diff                  = true,
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $transaction_name {
    $_transaction_name = $transaction_name
  } else {
    $_transaction_name = $name
  }

  $path = "Context/Transaction[#attribute/puppetName='${_transaction_name}']"

  if $ensure == 'absent' {
    $augeaschanges = "rm ${path}"
  } else {
    $set_name = "set ${path}/#attribute/puppetName ${_transaction_name}"
    $set_factory = "set ${path}/#attribute/factory ${factory}"

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

    $augeaschanges = delete_undef_values(flatten([
      $set_name,
      $set_factory,
      $_additional_attributes,
      $_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-transaction-${name}":
    lens      => 'Xml.lns',
    incl      => "${catalina_base}/conf/context.xml",
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
