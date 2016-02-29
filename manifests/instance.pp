# Definition: tomcat::instance
#
# This define installs an instance of Tomcat.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation. This parameter only
#   affects the instance when $install_from_source is true. Default:
#   $tomcat::catalina_home
# - $catalina_base is the base directory for the Tomcat instance if different
#   from $catalina_home. This parameter only affects the instance when
#   $install_from_source is true. Default: $catalina_home
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
# - $package_options to pass extra options to the package resource.
# - $user is the owner of the tomcat home and base. Default: $tomcat::user
# - $group is the group of the tomcat home and base. Default: $tomcat::group
define tomcat::instance (
  $catalina_home          = undef,
  $catalina_base          = undef,
  $install_from_source    = $::tomcat::install_from_source,
  $source_url             = undef,
  $source_strip_first_dir = undef,
  $package_ensure         = undef,
  $package_name           = undef,
  $package_options        = undef,
  $user                   = $::tomcat::user,
  $group                  = $::tomcat::group,
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

  if ! $install_from_source and ($catalina_home or $catalina_base) {
    warning('Setting $catalina_home or $catalina_base when not installing from source doesn\'t affect the installation.')
  }

  if ! $catalina_home {
    $_catalina_home = $::tomcat::catalina_home
  } else {
    $_catalina_home = $catalina_home
  }

  if ! $catalina_base {
    $_catalina_base = $::tomcat::catalina_home
  } else {
    $_catalina_base = $catalina_base
  }

  if $install_from_source {
    file { $_catalina_base:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0750',
    }
    if ! $source_strip_first_dir {
      $source_strip = true
    } else {
      $source_strip = $source_strip_first_dir
    }

    tomcat::instance::source { $name:
      catalina_home          => $_catalina_home,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip,
      user                   => $user,
      group                  => $group,
      require                => File[$_catalina_base],
    }
    if $_catalina_home != $_catalina_base {
      # Configure additional instances in custom catalina_base
      $dir_list = [
        "${_catalina_base}/bin",
        "${_catalina_base}/conf",
        "${_catalina_base}/lib",
        "${_catalina_base}/logs",
        "${_catalina_base}/temp",
        "${_catalina_base}/webapps",
        "${_catalina_base}/work",
      ]
      file { $dir_list:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '2770',
      }
      $copy_from_home_list = [
        "${_catalina_base}/conf/catalina.policy",
        "${_catalina_base}/conf/context.xml",
        "${_catalina_base}/conf/logging.properties",
        "${_catalina_base}/conf/server.xml",
        "${_catalina_base}/conf/web.xml",
      ]
      tomcat::instance::copy_from_home { $copy_from_home_list:
        catalina_home => $_catalina_home,
        user          => $user,
        group         => $group,
        require       => Tomcat::Instance::Source[$name],
      }
      tomcat::config::properties { "${_catalina_base} catalina.properties":
        catalina_base => $_catalina_base,
        catalina_home => $_catalina_home,
        user          => $user,
        group         => $group,
        require       => Tomcat::Instance::Source[$name],
      }
    }
  } else {
    tomcat::instance::package { $package_name:
      package_ensure  => $package_ensure,
      package_options => $package_options,
    }
  }
}
