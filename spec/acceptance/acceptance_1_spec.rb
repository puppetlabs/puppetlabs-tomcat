require 'spec_helper_acceptance'

#fact based two stage confine

#confine array
confine_array = [
  (fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04'),
  ($::osfamily == 'RedHat' and $::operatingsystemmajrelease == '5')
]

stop_test = false
stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up} || confine_array.any?

describe 'Acceptance case one' do , :unless => stop_test do

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{'tomcat':}
      class{'java':}
      class{'gcc':}

      $java_home = $::osfamily ? {
        'RedHat' => '/etc/alternatives/java_sdk',
        'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
        default  => undef
      }

      tomcat::instance { 'tomcat_one':
        source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.9/bin/apache-tomcat-8.0.9.tar.gz',
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
      }->
      staging::extract { 'commons-daemon-native.tar.gz':
        source => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-native.tar.gz",
        target => "/opt/apache-tomcat/tomcat8-jsvc/bin",
        unless => "test -d /opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src",
      }->
      exec { 'configure jsvc':
        command  => "JAVA_HOME=${java_home} configure --with-java=${java_home}",
        creates  => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/Makefile",
        cwd      => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        require  => [ Class['gcc'], Class['java'] ],
        provider => shell,
      }->
      exec { 'make jsvc':
        command  => 'make',
        creates  => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
        cwd      => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        provider => shell,
      }->
      file { 'jsvc':
        ensure => link,
        path   => "/opt/apache-tomcat/tomcat8-jsvc/bin/jsvc",
        target => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
      }->
      tomcat::config::server { 'tomcat8-jsvc':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        port          => '80',
      }->
      tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
      }->
      tomcat::config::server::connector { 'tomcat8-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'false',
      }->
      tomcat::war { 'war_one.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source => 'https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war',
      }->
      tomcat::setenv::entry { 'JAVA_HOME':
        base_path => '/opt/apache-tomcat/tomcat8-jsvc/bin',
        value     => $java_home,
      }->
      tomcat::service { 'jsvc-default':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        #java_home     => $java_home,
        #not sure if jave_home is required????
        use_jsvc      => true,
      }
      EOS
      #is 0 the correct exit code??? keeps exiting 2
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be(0)
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should be serving a page on port 80' do
      shell("/usr/bin/curl localhost:80/war_one/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'Stop tomcat with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::service{ 'tomcat_one':
        service_ensure => 'false',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not be serving a page on port 80' do
      shell("/usr/bin/curl localhost:80/war_one/hello.jsp") do |r|
        r.stdout.should match(/404/)
      end
    end
  end

  context 'Start Tomcat with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::service{ 'tomcat_one':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        service_ensure => 'true',
        # the docs dont say what valid values are for service_ensure
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should be serving a page on port 80' do
      shell("/usr/bin/curl localhost:80/war_one/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'un-deploy the war with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::war { 'war_one.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source => 'https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not have deployed the war' do
      shell('/usr/bin/curl localhost:80/war_one/sample.war', {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/The requested resource is not available/)
      end
    end
    it 'Should still have the server running on port 80' do
      shell('/usr/bin/curl localhost:80', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
  end

  context 'remove the connector with verification' do
    # Does a removing a this connector disable http service???
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'absent',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not be able to serve pages over port 80' do
      shell("/usr/bin/curl localhost:80") do |r|
        r.stdout.should match(/SERVER STUFF/)
      end
    end
  end

  context 'strange configurations????' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::connector { 'tomcat8-jsvc':
        parent_service => '',
        additional_attributes => {
          'somePARAM' => 'YO DOG!'
        },
        attributes_to_remove => {
          'redirectPort' => 443
        },
      }
      tomcat::service{ 'tomcat_one':
        start_command => '',
        stop_command => '',
        service_name => '',
      }
      tomcat::config::server::engine{ 'my_engine':
        default_host => '',
        background_processor_delay => '',
        background_processor_delay_ensure => '',
        class_name => '',
        class_name_ensure => '',
        engine_name => '',
        jvm_rout_ensure => '',
        parent_service => '',
        start_stop_threads => '',
        start_stop_threads_ensure => '',
      }
      tomcat::config::server::host{ 'my_host':
        app_base => '',
        host_ensure => '',
        host_name => '',
        attributes_to_remove => {
          #think I need to add atributes first????

        },
        additional_attributes => {
          hero_name => 'sparkle_pony',
        }
      }
      tomcat::config::server::valve{ 'my_valve':
        class_name => '',
        valve_ensure => '',

      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      sleep 10
    end
    it 'Should countain the correct settings in the xml file' do
      shell('cat /opt/apache-tomcat/tomcat8-jsvc/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        # single assert for each thing configurable in xml
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
        r.stdout.should match(/SOME STUFF/)
      end
    end
  end
end
