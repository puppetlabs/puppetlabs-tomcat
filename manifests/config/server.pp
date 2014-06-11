#
#
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
  },
  $extra_content           = undef,
  $extra_source            = undef,
) {
  include concat::setup

  concat { "${catalina_base}/conf/server.xml": }

  concat::fragment { "server-${name}-header":
    target  => "${catalina_base}/conf/server.xml",
    order   => 0,
    content => template('tomcat/config/_server.xml_header.erb'),
  }

  if $extra_content {
    concat::fragment { "server-${name}-extra-content":
      target  => "${catalina_base}/conf/server.xml",
      content => $extra_content,
    }
  }

  if $extra_source {
    concat::fragment { "server-${name}-extra-content":
      target  => "${catalina_base}/conf/server.xml",
      source => $extra_source,
    }
  }

  concat::fragment { "server-${name}-footer":
    target  => "${catalina_base}/conf/server.xml",
    order   => 99,
    content => template('tomcat/config/_server.xml_footer.erb'),
  }
}
