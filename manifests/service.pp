# Definition: tomcat::service
#
# Service management for Tomcat.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - $catalina_base is the base directory for the Tomcat installation.
# - Whether or not to $use_jsvc for service management. Boolean defaulting to
#   true. One of $use_jsvc and $use_init must be true.
# - $service_ensure is passed on to the service resource.
# - Whether or not to $use_init scripts for service management. Boolean
#   defaulting to false. One of $use_jsvc and $use_init must be true.
# - The $service_name to use when $use_init is true.
define tomcat::service (
  $catalina_home  = $::tomcat::catalina_home,
  $catalina_base  = $::tomcat::catalina_home,
  $use_jsvc       = true,
  $service_ensure = running,
  $use_init       = false,
  $service_name   = undef,
) {

  validate_bool($use_jsvc)
  validate_bool($use_init)

  if $use_jsvc and $use_init {
    fail('Only one of $use_jsvc and $use_init can be set to true')
  }

  if $use_init and ! $service_name {
    fail('$service_name must be specified when $use_init is set to true')
  }

  if ! $use_init and ! $use_jsvc {
    fail('One of $use_init and $use_jsvc must be set to true')
  }

  if $use_jsvc {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    $_start        =  "export CATALINA_HOME=${catalina_home}; export CATALINA_BASE=${catalina_base};
      \$CATALINA_HOME/bin/jsvc \
        -user ${::tomcat::user} \
        -classpath \$CATALINA_HOME/bin/bootstrap.jar:\$CATALINA_HOME/bin/tomcat-juli.jar \
        -outfile \$CATALINA_BASE/logs/catalina.out \
        -errfile \$CATALINA_BASE/logs/catalina.err \
        -pidfile \$CATALINA_BASE/logs/jsvc.pid \
        -Dcatalina.home=\$CATALINA_HOME \
        -Dcatalina.base=\$CATALINA_BASE \
        -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
        -Djava.util.logging.config.file=\$CATALINA_BASE/conf/logging.properties \
        org.apache.catalina.startup.Bootstrap"
    $_stop         = "export CATALINA_HOME=${catalina_home}; export CATALINA_BASE=${catalina_base};
      \$CATALINA_HOME/bin/jsvc \
        -pidfile \$CATALINA_BASE/logs/jsvc.pid \
        -stop org.apache.catalina.startup.Bootstrap"
    $_status       = "ps p `cat ${catalina_base}/logs/jsvc.pid` > /dev/null"
  } elsif $use_init {
    $_service_name = $service_name
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = undef
    $_stop         = undef
    $_status       = undef
  }

  service { $_service_name:
    ensure     => $service_ensure,
    hasstatus  => $_hasstatus,
    hasrestart => $_hasrestart,
    start      => $_start,
    stop       => $_stop,
    status     => $_status,
  }
}
