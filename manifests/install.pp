define tomcat::install (
  $catalina_home          = $::tomcat::catalina_home,
  $catalina_base          = $::tomcat::catalina_home,
  $install_from_source    = true,
  $source_url             = undef,
  $source_strip_first_dir = undef,
  $package_ensure         = undef,
  $package_name           = undef,
) {

  validate_bool($install_from_source)

  if $install_from_source and ! $source_url {
    fail("If installing from source $source_url must be specified")
  }

  if ! $install_from_source and ! $package_name {
    fail("If not installing from source $package_name must be specified")
  }

  if $install_from_source {
    if ! $source_strip_first_dir and $::osfamily != 'Solaris' {
      $source_strip = true
    } else {
      $source_strip = $source_strip_first_dir
    }

    tomcat::install::source { $name:
      catalina_home          => $catalina_home,
      catalina_base          => $catalina_base,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip,
      require                => File[$catalina_base],
    }
  } else {
    tomcat::install::package { $package_name:
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
