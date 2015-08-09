# Definition: tomcat::instance::package
#
# Private define to install Tomcat from a package.
#
# Parameters:
# - $package_ensure is the ensure passed to the package resource.
# - The $package_name you want to install.
define tomcat::instance::package (
  $package_ensure = 'installed',
  $package_name = undef,
  $package_version = undef,
  $user = $::tomcat::user,
  $group = $::tomcat::group,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }


  if $package_name {
    $_package_name = $package_name
  } else {
    $_package_name = $name
  }

  package { $_package_name:
    ensure => $package_ensure
  }


  case $::operatingsystem {
    Ubuntu, Debian: {

      validate_re($package_version, '7|8',
      "package_version should be either 7 or 8 not \"${package_version}\"")

      # Allow tomcat  group to read logs
      file { "/var/log/tomcat${package_version}":
        ensure  => directory,
        owner   => $user,
        group   => adm,
        mode    => '0750',
        require => Package[$_package_name],
      }

      augeas {'default user':
        context => "/etc/default/tomcat${package_version}",
        changes => [
          "set TOMCAT${package_version}_USER ${user}",
          "set TOMCAT${package_version}_GROUP ${group}",
        ]
      }

      # Fix up some permissions for user changes
      file {"/var/cache/tomcat${tomcat_version}":
        owner   => $user,
        group   => "adm",
      }
      file {"/var/cache/tomcat${tomcat_version}/Catalina":
        owner   => $user,
        group   => $group,
        recurse => true,
      }
      file {"/var/lib/tomcat${tomcat_version}/common":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/common/classes":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/server":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/server/classes":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/shared":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/shared/classes":
        owner   => $user,
        group   => $group,
      }
      file {"/var/lib/tomcat${tomcat_version}/webapps":
        owner   => $user,
        group   => $group,
      }

    }

    default: {
        # When trying on Solaris or Redhat expect a bucket of fail
        fail ('This OS is not supported for setting a user for the package install')
    }
  }
}

