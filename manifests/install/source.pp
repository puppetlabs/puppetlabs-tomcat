define tomcat::install::source (
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
