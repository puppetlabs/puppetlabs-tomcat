# Definition: tomcat::war
#
# Manage deployment of WAR files.
#
# Parameters:
# @param catalina_base is the base directory for the Tomcat installation
# @param app_base is the path relative to $catalina_base to deploy the WAR to.
#        Defaults to 'webapps'.
# @param deployment_path Optional. Only one of $app_base and $deployment_path
#        can be specified.
# @param war_ensure specifies whether you are trying to add or remove the WAR.
#        Valid values are 'present' and 'absent'. Defaults to 'present'.
# @param war_name Optional. Defaults to $name.
# @param war_purge is a boolean specifying whether or not to purge the exploded WAR
#        directory. Defaults to true. Only applicable when $war_ensure is 'absent'
#        or 'false'. Note: if tomcat is running and autodeploy is on, setting
#        $war_purge to false won't stop tomcat from auto-undeploying exploded WARs.
# @param war_source is the source to deploy the WAR from. Currently supports
#        http(s)://, puppet://, and ftp:// paths. $war_source must be specified
#        unless $war_ensure is set to 'false' or 'absent'.
# @param allow_insecure Specifies if HTTPS errors should be ignored when
#        downloading the war tarball. Valid options: `true` and `false`.
#        Defaults to `false`.
# @param user specifies the user of the tomcat war file.
#        Defaults to 'tomcat'.
# @param group specifies the user group of the tomcat war file.
#        Defaults to 'tomcat'.
define tomcat::war(
  $catalina_base                       = undef,
  $app_base                            = undef,
  $deployment_path                     = undef,
  Enum['present','absent'] $war_ensure = 'present',
  $war_name                            = undef,
  Boolean $war_purge                   = true,
  $war_source                          = undef,
  Boolean $allow_insecure              = false,
  $user                                = 'tomcat',
  $group                               = 'tomcat',
) {
  include ::tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if $app_base and $deployment_path {
    fail('Only one of $app_base and $deployment_path can be specified.')
  }

  if $war_name {
    $_war_name = $war_name
  } else {
    $_war_name = $name
  }

  if $_war_name !~ /\.war$/ {
    fail('war_name must end with .war')
  }

  if $deployment_path {
    $_deployment_path = $deployment_path
  } else {
    if $app_base {
      $_app_base = $app_base
    } else {
      $_app_base = 'webapps'
    }
    $_deployment_path = "${_catalina_base}/${_app_base}"
  }

  if $war_ensure =~ /^(absent|false)$/ {
    file { "${_deployment_path}/${_war_name}":
      ensure => absent,
      force  => false,
    }
    if $war_purge {
      $war_dir_name = regsubst($_war_name, '\.war$', '')
      if $war_dir_name != '' {
        file { "${_deployment_path}/${war_dir_name}":
          ensure => absent,
          force  => true,
        }
      }
    }
  } else {
    if ! $war_source {
      fail('$war_source must be specified if you aren\'t removing the WAR')
    }
    archive { "tomcat::war ${name}":
      extract        => false,
      source         => $war_source,
      path           => "${_deployment_path}/${_war_name}",
      allow_insecure => $allow_insecure,
      user           => $user,
      group          => $group,
    }
  }
}
