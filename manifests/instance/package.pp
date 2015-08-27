# Definition: tomcat::instance::package
#
# Private define to install Tomcat from a package.
#
# Parameters:
# - $package_ensure is the ensure passed to the package resource.
# - The $package_name you want to install.
# - $package_options to pass extra options to the package resource.
define tomcat::instance::package (
  $package_ensure  = 'installed',
  $package_name    = undef,
  $package_options = undef,
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
    ensure          => $package_ensure,
    install_options => $package_options,
  }

}
