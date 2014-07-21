# Definition tomcat::setenv::entry
#
# This define adds an entry to the setenv.sh script.
#
# Parameters:
# - $value is the value of the parameter you're setting
# - $ensure whether the fragment should be present or absent.
# - $base_path is the path to create the setenv.sh script under. Should be
#   either $catalina_base/bin or $catalina_home/bin.
# - $parameter is the parameter you're setting. Defaults to $name.
# - $quote_char is the optional character to quote the value with.
define tomcat::setenv::entry (
  $value,
  $ensure     = 'present',
  $base_path  = "${::tomcat::catalina_home}/bin",
  $param      = $name,
  $quote_char = undef,
) {

  if ! defined(Concat["${base_path}/setenv.sh"]) {
    concat { "${base_path}/setenv.sh":
      owner => $::tomcat::user,
      group => $::tomcat::group,
    }
  }

  concat::fragment { "setenv-${name}":
    ensure  => $ensure,
    target  => "${base_path}/setenv.sh",
    content => $quote_char ? {
      undef   => inline_template("<%= param %>=<%= value %>"),
      default => inline_template("<%= param %>=<%= quote_char %><%= value %><%= quote_char %>"),
    },
  }
}
