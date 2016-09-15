#
define tomcat::install (
  $catalina_home          = undef,
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
  $_catalina_home = pick($catalina_home, $::tomcat::catalina_home, $name)
  $_install_from_source = pick($install_from_source, $::tomcat::install_from_source)
  $_user = pick($user, $::tomcat::user)
  $_group = pick($group, $::tomcat::group)
  $_manage_user = pick($manage_user, $::tomcat::manage_user)
  $_manage_group = pick($manage_group, $::tomcat::manage_group)
  validate_bool($_install_from_source, $source_strip_first_dir)
  tag(sha1($_catalina_home))

  if $_install_from_source {
    if $_manage_user {
      ensure_resource('user', $_user, {
        ensure => present,
        gid    => $_group,
      })
    }
    if $_manage_group {
      ensure_resource('group', $_group, {
        ensure => present,
      })
    }
    tomcat::install::source { $name:
      catalina_home          => $_catalina_home,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip_first_dir,
      user                   => $_user,
      group                  => $_group,
    }
  } else {
    tomcat::install::package { $package_name:
      package_ensure  => $package_ensure,
      package_options => $package_options,
    }
  }
}
