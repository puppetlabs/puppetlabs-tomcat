define tomcat::service (
  $catalina_home  = $::tomcat::catalina_home,
  $catalina_base  = $::tomcat::catalina_home,
  $use_jsvc       = true,
  $service_ensure = running,
) {

  service { "tomcat-${name}":
    ensure => $service_ensure,
    hasstatus      => false,
    hasrestart     => false,
    start          => "export CATALINA_HOME=${catalina_home}; export CATALINA_BASE=${catalina_base};
      \$CATALINA_HOME/bin/jsvc \
        -classpath \$CATALINA_HOME/bin/bootstrap.jar:\$CATALINA_HOME/bin/tomcat-juli.jar \
        -outfile \$CATALINA_BASE/logs/catalina.out \
        -errfile \$CATALINA_BASE/logs/catalina.err \
        -pidfile \$CATALINA_BASE/logs/jsvc.pid \
        -Dcatalina.home=\$CATALINA_HOME \
        -Dcatalina.base=\$CATALINA_BASE \
        -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
        -Djava.util.logging.config.file=\$CATALINA_BASE/conf/logging.properties \
        org.apache.catalina.startup.Bootstrap",
    stop           => "export CATALINA_HOME=${catalina_home}; export CATALINA_BASE=${catalina_base};
      \$CATALINA_HOME/bin/jsvc \
        -pidfile \$CATALINA_BASE/logs/jsvc.pid \
        -stop org.apache.catalina.startup.Bootstrap",
    status         => "ps p `cat ${catalina_base}/logs/jsvc.pid` > /dev/null",
  }

}
