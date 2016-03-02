# Definition tomcat::setenv::entry
#
# This define adds an entry to the setenv.sh script.
#
# Parameters:
# - $value is the value of the parameter you're setting
# - $ensure whether the fragment should be present or absent.
# - $config_file is the path to the config file to edit
# - $param is the parameter you're setting. Defaults to $name.
# - $quote_char is the optional character to quote the value with.
# - $order is the optional order to the param in the file. Defaults to 10
# - (Deprecated) $base_path is the path to create the setenv.sh script under. Should be
#   either $catalina_base/bin or $catalina_home/bin.
define tomcat::setenv::entry (
  $value,
  $ensure        = 'present',
  $catalina_home = undef,
  $config_file   = undef,
  $param         = $name,
  $quote_char    = undef,
  $order         = '10',
  $addto         = undef,
  # Deprecated
  $base_path     = undef,
) {
  include tomcat
  $_catalina_home = pick($catalina_home, $::tomcat::catalina_home)
  $home_sha = sha1($_catalina_home)
  tag($home_sha)

  Tomcat::Install <| tag == $home_sha |>
  -> Tomcat::Setenv::Entry[$name]

  if $base_path {
    warning('The $base_path parameter is deprecated; please use catalina_home or config_file instead')
    $_config_file = "${base_path}/setenv.sh"
  } else {
    $_config_file = $config_file ? {
      undef   => "${_catalina_home}/bin/setenv.sh",
      default => $config_file,
    }
  }

  if ! $quote_char {
    $_quote_char = ''
  } else {
    $_quote_char = $quote_char
  }

  if ! defined(Concat[$_config_file]) {
    concat { $_config_file:
      owner          => $::tomcat::user,
      group          => $::tomcat::group,
      ensure_newline => true,
    }
  }

  if $addto {
    $_content = inline_template('export <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char %> ; export <%= @addto %>="$<%= @addto %> $<%= @param %>"')
  } else {
    $_content = inline_template('export <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char %>')
  }
  concat::fragment { "setenv-${name}":
    ensure  => $ensure,
    target  => $_config_file,
    content => $_content,
    order   => $order,
  }
}
