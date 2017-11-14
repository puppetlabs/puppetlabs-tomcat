# Definition: tomcat::service
#
# Service management for Tomcat.
#
# Parameters:
# @param catalina_home is the root of the Tomcat installation.
# @param catalina_base is the base directory for the Tomcat installation.
# @param use_jsvc Whether or not to use jsvc for service management. Boolean defaulting to
#        false. If both $use_jsvc and $use_init are false,
#        $CATALINA_BASE/bin/catalina.sh start and $CATALIN/A_BASE/bin/catalina.sh
#        stop are used for service management.
# @param use_init Whether or not to use init for service management. Boolean defaulting to
#        false. If both $use_jsvc and $use_init are false,
#        $CATALINA_BASE/bin/catalina.sh start and $CATALINA_BASE/bin/catalina.sh
#        stop are used for service management.
# @param java_home If using jsvc, optionally set java_home.  Has no affect unless
#        $use_jsvc = true.
# @param service_ensure is passed on to the service resource.
# @param service_enable specifies whether the tomcat service should be enabled on
#        on boot. Valid options are `true` or `false`. Defaults to `undef`, will be
#        programmatically set to `true` if $use_init is true AND
#        $service_ensure == 'running'
# @param service_name The name to use for the packaged init script
# @param start_command The start command to use for the service
# @param stop_command The stop command to use for the service
# @param status_command The status command to use for the service
# @param user is the user of the jsvc process.
define tomcat::service (
  $catalina_home                    = undef,
  $catalina_base                    = undef,
  Boolean $use_jsvc                 = false,
  Boolean $use_init                 = false,
  $java_home                        = undef,
  $service_ensure                   = running,
  Optional[Boolean] $service_enable = undef,
  $service_name                     = undef,
  $start_command                    = undef,
  $stop_command                     = undef,
  $status_command                   = undef,
  $user                             = undef,
) {
  include ::tomcat
  $_user = pick($user, $::tomcat::user)
  # XXX Backwards compatibility: If the user declares a base but not a home, we
  # assume they are in compatibility mode
  if $catalina_base {
    $_catalina_home = pick($catalina_home, $catalina_base)
  } else {
    $_catalina_home = pick($catalina_home, $tomcat::catalina_home)
  }
  $_catalina_base = pick($catalina_base, $_catalina_home) #default to home
  tag(sha1($_catalina_home))
  tag(sha1($_catalina_base))

  if $use_init and ! $use_jsvc and ! $service_name {
    fail('service_name must be specified when using the package init script')
  }

  if $use_init and ! $use_jsvc and $catalina_home {
    warning('catalina_home has no effect when using the package init script; ignoring')
  }

  if $use_jsvc and $service_name {
    warning('service_name has no effect when using jsvc; ignoring')
  }

  if ! $use_init and $service_enable != undef {
    warning('service_enable has no effect without an init script; ignoring')
  }

  if ! $use_jsvc and $java_home {
    warning('java_home has no effect when not using jsvc; ignoring')
  }

  if $use_jsvc and $use_init {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = "service tomcat-${name} start"
    $_stop         = "service tomcat-${name} stop"
    $_status       = "service tomcat-${name} status"
    $_provider     = undef
    # Template uses:
    # - $_catalina_home
    # - $_catalina_base
    # - $java_home
    # - $_user
    file { "/etc/init.d/tomcat-${name}":
      mode    => '0755',
      content => template('tomcat/jsvc-init.erb'),
    }
  } elsif $use_jsvc {
    if $java_home {
      $_jsvc_home = "--java-home ${java_home} "
      #$_jsvc_home = "-home ${java_home} "
    } else {
      $_jsvc_home = undef
    }
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    $daemon_sh = "${_catalina_home}/bin/daemon.sh \
                  --catalina-home ${_catalina_home} \
                  --catalina-base ${_catalina_base} \
                  ${_jsvc_home}\
                  --tomcat-user ${_user} \
                  --catalina-pid ${_catalina_base}/logs/jsvc.pid"
    # Query the version first to make sure it's all compatible
    $daemon_command = "${daemon_sh} version && ${daemon_sh}"
    if $start_command {
      $_start = $start_command
    } else {
      $_start = "${daemon_command} start"

      #$_start = "export CATALINA_HOME=${_catalina_home}; export CATALINA_BASE=${_catalina_base}; \
      #           \$CATALINA_HOME/bin/jsvc \
      #             ${_jsvc_home}-user ${_user} \
      #             -classpath \$CATALINA_HOME/bin/bootstrap.jar:\$CATALINA_HOME/bin/tomcat-juli.jar \
      #             -outfile \$CATALINA_BASE/logs/catalina.out \
      #             -errfile \$CATALINA_BASE/logs/catalina.err \
      #             -pidfile \$CATALINA_BASE/logs/jsvc.pid \
      #             -Dcatalina.home=\$CATALINA_HOME \
      #             -Dcatalina.base=\$CATALINA_BASE \
      #             -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
      #             -Djava.util.logging.config.file=\$CATALINA_BASE/conf/logging.properties \
      #             org.apache.catalina.startup.Bootstrap"
    }
    if $stop_command {
      $_stop = $stop_command
    } else {
      $_stop = "${daemon_command} stop"

      #$_stop = "export CATALINA_HOME=${_catalina_home}; export CATALINA_BASE=${_catalina_base};
      #           \$CATALINA_HOME/bin/jsvc \
      #             -pidfile \$CATALINA_BASE/logs/jsvc.pid \
      #             -stop org.apache.catalina.startup.Bootstrap"
    }
    if $status_command {
      $_status = $status_command
    } else {
      $_status     = "ps p `cat ${_catalina_base}/logs/jsvc.pid` > /dev/null"
    }
    $_provider     = 'base'
  } elsif $use_init {
    $_service_name = $service_name
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = $start_command
    $_stop         = $stop_command
    $_status       = undef
    $_provider     = undef
  } else {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    $_start        = $start_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh start' ${_user}", # lint:ignore:140chars
      default => $start_command
    }
    $_stop         = $stop_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh stop' ${_user}", # lint:ignore:140chars
      default => $stop_command
    }
    $_status       = $status_command ? {
      undef   => "ps aux | grep 'catalina.base=${_catalina_base} ' | grep -v grep",
      default => $status_command
    }
    $_provider     = 'base'
  }

  if $use_init {
    if $service_enable != undef {
      $_service_enable = $service_enable
    } else {
      $_service_enable = $service_ensure ? {
        'running' => true,
        true      => true,
        default   => undef,
      }
    }
  } else {
    $_service_enable = undef
  }

  service { $_service_name:
    ensure     => $service_ensure,
    enable     => $_service_enable,
    hasstatus  => $_hasstatus,
    hasrestart => $_hasrestart,
    start      => $_start,
    stop       => $_stop,
    status     => $_status,
    provider   => $_provider,
  }
}
