define tomcat::config::server (
  $catalina_base           = $::tomcat::catalina_home,
  $class_name              = undef,
  $address                 = undef,
  $port                    = '8005',
  $shutdown                = 'SHUTDOWN',
  $warning                 = true,
  $listeners               = { 
    'org.apache.catalina.core.AprLifecycleListener' => {
      'SSLEngine' => 'on',
    },
    'org.apache.catalina.core.JreMemoryLeakPreventionListener' => {},
    'org.apache.catalina.mbeans.GlobalResourcesLifecycleListener' => {},
    'org.apache.catalina.core.ThreadLocalLeakPreventionListener' => {},
  },
  $global_naming_resources = {
    'UserDatabase' => {
      'auth'        => 'Container',
      'type'        => 'org.apache.catalina.UserDatabase',
      'description' => 'User database that can be updated and saved',
      'factory'     => 'org.apache.catalina.users.MemoryUserDatabaseFactory',
      'pathname'    => 'conf/tomcat-users.xml',
    },
  }
) {
  concat::fragment { "server-${name}-header":
    target  => "${catalina_base}/server.xml",
    order   => 0,
    content => template('tomcat/config/_server.xml_header.erb'),
  }

  concat::fragment { "server-${name}-footer":
    target  => "${catalina_base}/server.xml",
    order   => 0,
    content => template('tomcat/config/_server.xml_footer.erb'),
  }
}
