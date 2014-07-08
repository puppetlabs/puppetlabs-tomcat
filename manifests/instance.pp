# Definition: tomcat::instance
#
# This define installs an instance of Tomcat.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - $catalina_base is the base directory for the Tomcat installation.
# - $install_from_source is a boolean specifying whether or not to install from
#   source. Defaults to true.
# - The $source_url to install from. Required if $install_from_source is true.
# - $source_strip_first_dir is a boolean specifying whether or not to strip
#   the first directory when unpacking the source tarball. Defaults to true
#   when installing from source. Requires nanliu/staging > 0.4.0
# - $package_ensure when installing from package, what the ensure should be set
#   to in the package resource.
# - $package_name is the name of the package you want to install. Required if
#   $install_from_source is false.
define tomcat::instance (
  $catalina_home          = $::tomcat::catalina_home,
  $catalina_base          = $::tomcat::catalina_home,
  $install_from_source    = true,
  $source_url             = undef,
  $source_strip_first_dir = undef,
  $package_ensure         = undef,
  $package_name           = undef,
) {

  if $install_from_source {
    validate_bool($install_from_source)
  }
  if $source_strip_first_dir {
    validate_bool($source_strip_first_dir)
  }

  if $install_from_source and ! $source_url {
    fail('If installing from source $source_url must be specified')
  }

  if ! $install_from_source and ! $package_name {
    fail('If not installing from source $package_name must be specified')
  }

  if $install_from_source {
    if ! $source_strip_first_dir {
      $source_strip = true
    } else {
      $source_strip = $source_strip_first_dir
    }

    tomcat::instance::source { $name:
      catalina_home          => $catalina_home,
      catalina_base          => $catalina_base,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip,
      require                => File[$catalina_base],
    }
  } else {
    tomcat::instance::package { $package_name:
      package_ensure => $package_ensure,
    }
  }

  if $catalina_base != $catalina_home {
    file { $catalina_base:
      ensure => directory,
      owner  => $::tomcat::user,
      group  => $::tomcat::group,
    }
  }
}
