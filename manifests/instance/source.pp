# Definition: tomcat::instance::source
#
# Private define to install Tomcat from source.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - $catalina_base is the base directory for the Tomcat installation.
# - The $source_url to install from.
# - $source_strip_first_dir is a boolean specifying whether or not to strip
#   the first directory when unpacking the source tarball. Defaults to true
#   when installing from source on non-Solaris systems. Requires nanliu/staging
#   > 0.4.0
define tomcat::instance::source (
  $catalina_home,
  $catalina_base,
  $source_url,
  $source_strip_first_dir = undef,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $filename = regsubst($source_url, '.*/(.*)', '\1')

  staging::file { $filename:
    source => $source_url,
  }

  staging::extract { $filename:
    target  => $catalina_base,
    require => Staging::File[$filename],
    unless  => "test \"\$(ls -A ${catalina_base})\"",
    user    => $::tomcat::user,
    group   => $::tomcat::group,
    strip   => $source_strip_first_dir ? {
      true    => 1,
      default => undef,
    },
  }
}
