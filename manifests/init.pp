# == Class: tomcat
#
# Class to manage installation and configuration of Tomcat.
#
# === Parameters
#
# [*catalina_home*]
#   The base directory for the Tomcat installation.
#
# [*user*]
#   The user to run Tomcat as.
#
# [*group*]
#   The group to run Tomcat as.
#
# [*manage_user*]
#   Boolean specifying whether or not to manage the user. Defaults to true.
#
# [*manage_group*]
#   Boolean specifying whether or not to manage the group. Defaults to true.
#
class tomcat (
  $catalina_home = $::tomcat::params::catalina_home,
  $user          = $::tomcat::params::user,
  $group         = $::tomcat::params::group,
  $manage_user   = true,
  $manage_group  = true,
) inherits ::tomcat::params {
  validate_bool($manage_user)
  validate_bool($manage_group)

  case $::osfamily {
    'windows','Solaris','Darwin': {
      fail("Unsupported osfamily: ${::osfamily}")
    }
    default: { }
  }

  file { $catalina_home:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  if $manage_user {
    user { $user:
      ensure => present,
      gid    => $group
    }
  }

  if $manage_group {
    group { $group:
      ensure => present,
    }
  }
}
