#
define tomcat::install (
  $catalina_home          = $name,
  $install_from_source    = undef,

  # source options
  $source_url             = undef,
  $source_strip_first_dir = true,
  $user                   = undef,
  $group                  = undef,
  $manage_user            = undef,
  $manage_group           = undef,

  # package options
  $package_ensure         = undef,
  $package_name           = undef,
  $package_options        = undef,
) {
  include tomcat
  $_install_from_source = pick($install_from_source, $::tomcat::install_from_source)
  $_user = pick($user, $::tomcat::user)
  $_group = pick($group, $::tomcat::group)
  $_manage_user = pick($manage_user, $::tomcat::manage_user)
  $_manage_group = pick($manage_group, $::tomcat::manage_group)
  validate_bool($_install_from_source, $source_strip_first_dir)
  tag(sha1($catalina_home))

  if $_install_from_source {
    tomcat::install::source { $name:
      catalina_home          => $catalina_home,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip_first_dir,
      user                   => $_user,
      group                  => $_group,
      manage_user            => $_manage_user,
      manage_group           => $_manage_group,
    }
  } else {
    tomcat::install::package { $package_name:
      package_ensure  => $package_ensure,
      package_options => $package_options,
    }
  }
}
