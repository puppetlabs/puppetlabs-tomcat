#
#
define tomcat::config::service (
  $catalina_base   = $::tomcat::catalina_home,
  $custom_source   = undef,
  $custom_content  = undef,
  $class_name      = undef,
  $connectors      = [
    {
      'port'              => '8080',
      'protocol'          => 'HTTP/1.1',
      'connectionTimeout' => '20000',
      'redirectPort'      => '8443',
    },
    {
      'port'              => '8009',
      'protocol'          => 'AJP/1.3',
      'redirectPort'      => '8443',
    }
  ],
  # Engine configuration
  $engine_name         = 'Catalina',
  $engine_default_host = 'localhost',
  $engine_background_processor_delay = undef,
  $engine_class_name                 = undef,
  $engine_jvm_route                  = undef,
  $engine_start_stop_threads         = undef,
  $engine_hosts                      = {
    'attributes' => {
      'name' => 'localhost',
      'appBase' => 'webapps',
      'unpackWARs' => 'true',
      'autoDeploy' => 'true',
    },
    'Valve' => {
        'className' => 'org.apache.catalina.valves.AccessLogValve',
        'directory' => 'logs',
        'prefix'    => 'localhost_access_log',
        'suffix'    => '.txt',
        'pattern'   => '%h %l %u %t &quot;%r&quot; %s %b',
    },
  },
  $engine_realm                      = {
    'attributes' => {
      'className' => 'org.apache.catalina.realm.LockOutRealm',
    },
    'Realm'     => {
        'className'    => 'org.apache.catalina.realm.UserDatabaseRealm',
        'resourceName' => 'UserDatabase',
    },
  },
) {

  if $custom_content and $custom_source {
    fail('You can only specify one of $custom_content or $custom_source')
  }

  if $custom_content {
    $_content = $custom_content
    $_source  = undef
  } elsif $custom_source {
    $_content = undef
    $_source  = $custom_source
  } else {
    $_content = template('tomcat/config/_service.erb')
    $_source  = undef
  }

  concat::fragment { "service-${name}":
    target  => "$catalina_base/conf/server.xml",
    content => $_content,
    source  => $_source,
  }
}
