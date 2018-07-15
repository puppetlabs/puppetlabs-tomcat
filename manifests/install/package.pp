# @summary Private define to install Tomcat from a package.
#
# @api private
#
define tomcat::install::package (
  $package_ensure,
  $package_options,
  $package_name = $name,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { $package_name:
    ensure          => $package_ensure,
    install_options => $package_options,
  }
}
