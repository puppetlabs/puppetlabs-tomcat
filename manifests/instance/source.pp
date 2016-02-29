# Definition: tomcat::instance::source
#
# Private define to install Tomcat from source.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - The $source_url to install from.
# - $source_strip_first_dir is a boolean specifying whether or not to strip
#   the first directory when unpacking the source tarball. Defaults to true
#   when installing from source on non-Solaris systems. Requires nanliu/staging
#   > 0.4.0
# - $user is the user that the package should be installed under, default to tomcat
#   class defined user
# - $group is the group that the package should be installed under, default to tomcat
#   class defined group

define tomcat::instance::source (
  $catalina_home,
  $source_url,
  $source_strip_first_dir = undef,
  $user = $::tomcat::user,
  $group = $::tomcat::group,
) {
  include staging

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $source_strip_first_dir {
    $_strip = 1
  }

  $filename = regsubst($source_url, '.*/(.*)', '\1')

  if ! defined(Staging::File[$filename]) {
    staging::file { $filename:
      source => $source_url,
    }
  }

  staging::extract { "${name}-${filename}":
    source  => "${::staging::path}/tomcat/${filename}",
    target  => $catalina_home,
    require => Staging::File[$filename],
    unless  => "test \"\$(ls -A ${catalina_home})\"",
    user    => $user,
    group   => $group,
    strip   => $_strip,
  }
}
