# This code fragment downloads tomcat 8.0, compiles jsvc, then starts the service
#
class { 'tomcat': }
class { 'gcc': }
class { 'java': }

tomcat::instance { 'test':
  source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
}
-> archive { 'commons-daemon-native.tar.gz':
  extract      => true,
  cleanup      => false,
  path         => "${tomcat::catalina_home}/bin/commons-daemon-native.tar.gz",
  extract_path => "${tomcat::catalina_home}/bin",
  creates      => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src",
}
-> exec { 'configure jsvc':
  command  => 'JAVA_HOME=/etc/alternatives/java_sdk configure',
  creates  => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix/Makefile",
  cwd      => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix",
  path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix", # lint:ignore:140chars
  require  => [Class['gcc'], Class['java']],
  provider => shell,
}
-> exec { 'make jsvc':
  command  => 'make',
  creates  => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
  cwd      => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix",
  path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix", # lint:ignore:140chars
  provider => shell,
}
-> file { 'jsvc':
  ensure => link,
  path   => "${tomcat::catalina_home}/bin/jsvc",
  target => "${tomcat::catalina_home}/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
}
-> tomcat::service { 'default':
  use_jsvc => true,
}
