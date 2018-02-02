require 'spec_helper_acceptance'

stop_test = (UNSUPPORTED_PLATFORMS.any? { |up| fact('osfamily') == up } || SKIP_TOMCAT_8)

describe 'Tomcat Install source -defaults', docker: true, unless: stop_test do
  after :all do
    shell('pkill -f tomcat', acceptable_exit_codes: [0, 1])
    shell('rm -rf /opt/tomcat*', acceptable_exit_codes: [0, 1])
    shell('rm -rf /opt/apache-tomcat*', acceptable_exit_codes: [0, 1])
  end

  before :all do
    shell("curl --retry 5 --retry-delay 15 -k -o /tmp/sample.war '#{SAMPLE_WAR}'", acceptable_exit_codes: 0)
  end

  context 'Initial install Tomcat and verification' do
    pp = <<-MANIFEST
      class { 'java':}
      class { 'tomcat':
        catalina_home => '/opt/apache-tomcat8',
      }
      tomcat::install { '/opt/apache-tomcat8':
        source_url     => '#{TOMCAT8_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat8':
        catalina_base => '/opt/apache-tomcat8/tomcat8',
      }
      tomcat::config::server { 'tomcat8':
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        port          => '8105',
      }
      tomcat::config::server::connector { 'tomcat8-http':
        catalina_base         => '/opt/apache-tomcat8/tomcat8',
        port                  => '8180',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      tomcat::config::server::connector { 'tomcat8-ajp':
        catalina_base         => '/opt/apache-tomcat8/tomcat8',
        port                  => '8109',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      tomcat::war { 'tomcat8-sample.war':
        catalina_base  => '/opt/apache-tomcat8/tomcat8',
        war_source     => '/tmp/sample.war',
        war_name       => 'tomcat8-sample.war',
        allow_insecure => true,
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    it 'is serving a page on port 8180', retry: 5, retry_wait: 10 do
      shell('curl --retry 5 --retry-delay 15 localhost:8180') do |r|
        r.stdout.should eq('')
      end
    end
    it 'is serving a JSP page from the war', retry: 5, retry_wait: 10 do
      shell('curl --retry 5 --retry-delay 15 localhost:8180/tomcat8-sample/hello.jsp') do |r|
        r.stdout.should match(%r{Sample Application JSP Page})
      end
    end
  end

  context 'Stop tomcat' do
    pp = <<-MANIFEST
      tomcat::service { 'tomcat8':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/apache-tomcat8/tomcat8',
        service_ensure => stopped,
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'is not serving a page on port 8180', retry: 5, retry_wait: 10 do
      shell('curl localhost:8180', acceptable_exit_codes: 7)
    end
  end

  context 'Start Tomcat' do
    pp = <<-MANIFEST
      tomcat::service { 'tomcat8':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/apache-tomcat8/tomcat8',
        service_ensure => running,
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'is serving a page on port 8180', retry: 5, retry_wait: 10 do
      shell('curl --retry 5 --retry-delay 15 localhost:8180') do |r|
        r.stdout.should eq('')
      end
    end
  end

  context 'un-deploy the war' do
    pp = <<-MANIFEST
      tomcat::war { 'tomcat8-sample.war':
        war_ensure    => absent,
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        war_source    => '/tmp/sample.war',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'does not have deployed the war', retry: 5, retry_wait: 10 do
      shell('curl --retry 5 --retry-delay 15 localhost:8180/tomcat8-sample/hello.jsp', acceptable_exit_codes: 0) do |r|
        r.stdout.should eq('')
      end
    end
  end

  context 'remove the connector' do
    pp = <<-MANIFEST
      tomcat::config::server::connector { 'tomcat8-http':
        connector_ensure => absent,
        catalina_base    => '/opt/apache-tomcat8/tomcat8',
        port             => '8180',
        notify           => Tomcat::Service['tomcat8'],
      }
      tomcat::service { 'tomcat8':
        catalina_home => '/opt/apache-tomcat8',
        catalina_base => '/opt/apache-tomcat8/tomcat8'
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'is not able to serve pages over port 8180', retry: 5, retry_wait: 10 do
      shell('curl localhost:8180', acceptable_exit_codes: 7)
    end
  end

  context 'Service Configuration' do
    pp = <<-MANIFEST
      class{ 'tomcat':}
      tomcat::config::server::service { 'org.apache.catalina.core.StandardService':
        catalina_base     => '/opt/apache-tomcat8/tomcat8',
        class_name        => 'org.apache.catalina.core.StandardService',
        class_name_ensure => 'present',
        service_ensure    => 'present',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'shoud have a service named FooBar and a class names FooBar' do
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><\/Service>})
      end
    end
  end

  context 'add a valve' do
    pp = <<-MANIFEST
      tomcat::config::server::valve { 'logger':
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        class_name    => 'org.apache.catalina.valves.AccessLogValve',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the conf.xml file' do
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{<Valve className="org.apache.catalina.valves.AccessLogValve"><\/Valve>})
      end
    end
  end

  context 'remove a valve' do
    pp = <<-MANIFEST
      tomcat::config::server::valve { 'logger':
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        class_name    => 'org.apache.catalina.valves.AccessLogValve',
        valve_ensure  => 'absent',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the conf.xml file' do
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should_not match(%r{<Valve className="org.apache.catalina.valves.AccessLogValve"><\/Valve>})
      end
    end
  end

  context 'add engine and change settings' do
    pp_one = <<-MANIFEST
      tomcat::config::server::engine{'org.apache.catalina.core.StandardEngine':
        default_host               => 'localhost',
        catalina_base              => '/opt/apache-tomcat8/tomcat8',
        background_processor_delay => 5,
        parent_service             => 'org.apache.catalina.core.StandardService',
        start_stop_threads         => 3,
      }
    MANIFEST
    it 'applies the manifest to create the engine without error' do
      apply_manifest(pp_one, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the conf.xml file #5' do
      # validation
      v = '<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><Engine name="org.apache.catalina.core.StandardEngine" defaultHost="localhost" backgroundProcessorDelay="5" startStopThreads="3"><\/Engine>' # rubocop:disable Metrics/LineLength
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{#{v}})
      end
    end
    pp_two = <<-MANIFEST
      tomcat::config::server::engine { 'org.apache.catalina.core.StandardEngine':
        default_host               => 'localhost',
        catalina_base              => '/opt/apache-tomcat8/tomcat8',
        background_processor_delay => 999,
        parent_service             => 'org.apache.catalina.core.StandardService',
        start_stop_threads         => 555,
      }
    MANIFEST
    it 'applies the manifest to change the settings without error' do
      apply_manifest(pp_two, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the conf.xml file #999' do
      # validation
      v = '<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><Engine name="org.apache.catalina.core.StandardEngine" defaultHost="localhost" backgroundProcessorDelay="999" startStopThreads="555"><\/Engine>' # rubocop:disable Metrics/LineLength
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{#{v}})
      end
    end
  end

  context 'add a host then change settings' do
    pp_one = <<-MANIFEST
      tomcat::config::server::host { 'org.apache.catalina.core.StandardHost':
        app_base              => '/opt/apache-tomcat8/tomcat8/webapps',
        catalina_base         => '/opt/apache-tomcat8/tomcat8',
        host_name             => 'hulk-smash',
        additional_attributes => {
          astrological_sign => 'scorpio',
          favorite-beer     => 'PBR',
        },
      }
    MANIFEST
    it 'applies the manifest to create the engine without error' do
      apply_manifest(pp_one, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    # validation
    matches = ['<Host name="hulk-smash".*appBase="/opt/apache-tomcat8/tomcat8/webapps".*></Host>', '<Host name="hulk-smash".*astrological_sign="scorpio".*></Host>', '<Host name="hulk-smash".*favorite-beer="PBR".*></Host>'] # rubocop:disable Metrics/LineLength
    it 'has changed the conf.xml file #joined' do
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        matches.each do |m|
          r.stdout.should match(%r{#{m}})
        end
      end
    end
    pp_two = <<-MANIFEST
      tomcat::config::server::host { 'org.apache.catalina.core.StandardHost':
        app_base => '/opt/apache-tomcat8/tomcat8/webapps',
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        host_name => 'hulk-smash',
        additional_attributes => {
          astrological_sign => 'scorpio',
        },
        attributes_to_remove => [
          'favorite-beer',
        ],
      }
    MANIFEST
    it 'applies the manifest to remove a engine attribute without error' do
      apply_manifest(pp_two, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the conf.xml file #seperated' do
      # validation
      v = '<Host name="hulk-smash" appBase="/opt/apache-tomcat8/tomcat8/webapps" astrological_sign="scorpio"><\/Host>'
      shell('cat /opt/apache-tomcat8/tomcat8/conf/server.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{#{v}})
      end
    end
  end
  context 'add a context environment' do
    pp = <<-MANIFEST
      tomcat::config::context::environment { 'testEnvVar':
        catalina_base => '/opt/apache-tomcat8/tomcat8',
        type          => 'java.lang.String',
        value         => 'a value with a space',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'has changed the context.xml file' do
      shell('cat /opt/apache-tomcat8/tomcat8/conf/context.xml', acceptable_exit_codes: 0) do |r|
        r.stdout.should match(%r{<Environment name="testEnvVar" type="java.lang.String" value="a value with a space"><\/Environment>})
      end
    end
  end
end
