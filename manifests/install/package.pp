define tomcat::install::package (
  $package_ensure = 'installed',
  $pacakge_name = undef,
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

}
