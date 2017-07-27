#
define tomcat::install (
  $catalina_home                  = $name,
  Boolean $install_from_source    = true,

  # source options
  $source_url                     = undef,
  Boolean $source_strip_first_dir = true,
  $proxy_type                     = undef,
  $proxy_server                   = undef,
  $allow_insecure                 = false,
  $user                           = undef,
  $group                          = undef,
  $manage_user                    = undef,
  $manage_group                   = undef,
  $manage_home                    = undef,

  # package options
  $package_ensure                 = undef,
  $package_name                   = undef,
  $package_options                = undef,
) {
  include ::tomcat
  $_user = pick($user, $::tomcat::user)
  $_group = pick($group, $::tomcat::group)
  $_manage_user = pick($manage_user, $::tomcat::manage_user)
  $_manage_group = pick($manage_group, $::tomcat::manage_group)
  $_manage_home = pick($manage_home, $::tomcat::manage_home)
  tag(sha1($catalina_home))

  if $install_from_source {
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
      catalina_home          => $catalina_home,
      manage_home            => $_manage_home,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip_first_dir,
      proxy_type             => $proxy_type,
      proxy_server           => $proxy_server,
      allow_insecure         => $allow_insecure,
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
