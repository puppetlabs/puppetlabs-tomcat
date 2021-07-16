# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Two different installations with two instances each of Tomcat 7 in the same manifest', docker: true do
  after :all do
    run_shell('pkill -f tomcat', expect_failures: true)
    run_shell('rm -rf /opt/tomcat*', expect_failures: true)
    run_shell('rm -rf /opt/apache-tomcat*', expect_failures: true)
  end

  context 'Initial install Tomcat and verification' do
    pp = <<-MANIFEST
      class { 'java':}
      tomcat::install { 'tomcat7':
        catalina_home  => '/opt/apache-tomcat7',
        source_url     => '#{TOMCAT7_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat7-first':
        catalina_home => '/opt/apache-tomcat7',
        catalina_base => '/opt/tomcat7-first',
      }
      tomcat::instance { 'tomcat7-second':
        catalina_home => '/opt/apache-tomcat7',
        catalina_base => '/opt/tomcat7-second',
      }
      tomcat::config::server { 'tomcat7-first':
        catalina_base => '/opt/tomcat7-first',
        port          => '8205',
      }
      tomcat::config::server { 'tomcat7-second':
        catalina_base => '/opt/tomcat7-second',
        port          => '8206',
      }
      tomcat::config::server::connector { 'tomcat7-first-http':
        catalina_base         => '/opt/tomcat7-first',
        port                  => '8280',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat7-first-ajp':
        catalina_base         => '/opt/tomcat7-first',
        port                  => '8209',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat7-second-http':
        catalina_base         => '/opt/tomcat7-second',
        port                  => '8281',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::config::server::connector { 'tomcat7-second-ajp':
        catalina_base         => '/opt/tomcat7-second',
        port                  => '8210',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::war { 'first tomcat7-sample.war':
        catalina_base  => '/opt/tomcat7-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7#sample.war',
        allow_insecure => true,
      }
      tomcat::war { 'second tomcat7-sample.war':
        catalina_base  => '/opt/tomcat7-second',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7#sample.war',
        allow_insecure => true,
      }


      tomcat::install { 'tomcat7078':
        catalina_home  => '/opt/apache-tomcat7078',
        source_url     => '#{TOMCAT7_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat7078-first':
        catalina_home => '/opt/apache-tomcat7078',
        catalina_base => '/opt/tomcat7078-first',
      }
      tomcat::instance { 'tomcat7078-second':
        catalina_home => '/opt/apache-tomcat7078',
        catalina_base => '/opt/tomcat7078-second',
      }
      tomcat::config::server { 'tomcat7078-first':
        catalina_base => '/opt/tomcat7078-first',
        port          => '8305',
      }
      tomcat::config::server { 'tomcat7078-second':
        catalina_base => '/opt/tomcat7078-second',
        port          => '8306',
      }
      tomcat::config::server::connector { 'tomcat7078-first-http':
        catalina_base         => '/opt/tomcat7078-first',
        port                  => '8380',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat7078-second-http':
        catalina_base         => '/opt/tomcat7078-second',
        port                  => '8381',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::config::server::connector { 'tomcat7078-first-ajp':
        catalina_base         => '/opt/tomcat7078-first',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat7078-second-ajp':
        catalina_base         => '/opt/tomcat7078-second',
        port                  => '8310',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::war { 'first tomcat7078-sample.war':
        catalina_base  => '/opt/tomcat7078-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7078-sample.war',
        allow_insecure => true,
      }
      tomcat::war { 'second tomcat7078-sample.war':
        catalina_base  => '/opt/tomcat7078-second',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7078-sample.war',
        allow_insecure => true,
      }
    MANIFEST
    it 'applies the manifest without error' do
      idempotent_apply(pp)
    end
    # test the war
    it 'tomcat7-first should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8280/tomcat7/sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
    it 'tomcat7-second should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8281/tomcat7/sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
    it 'tomcat7078-first should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8380/tomcat7078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
    it 'tomcat7078-second should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8381/tomcat7078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
  end

  context 'Stop tomcat service' do
    pp = <<-MANIFEST
      tomcat::service { 'tomcat7-first':
        catalina_home  => '/opt/apache-tomcat7',
        catalina_base  => '/opt/tomcat7-first',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat7-second':
        catalina_home  => '/opt/apache-tomcat7',
        catalina_base  => '/opt/tomcat7-second',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat7078-first':
        catalina_home  => '/opt/apache-tomcat7078',
        catalina_base  => '/opt/tomcat7078-first',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat7078-second':
        catalina_home  => '/opt/apache-tomcat7078',
        catalina_base  => '/opt/tomcat7078-second',
        service_ensure => 'stopped',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'tomcat7-first should not be serving a page on port 8280', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8280', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
    it 'tomcat7-second should not be serving a page on port 8281', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8281', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
    it 'tomcat7078-first should not be serving a page on port 8380', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8380', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
    it 'tomcat7078-second should not be serving a page on port 8381', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8381', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
  end

  context 'Start Tomcat without war' do
    pp = <<-MANIFEST
      tomcat::war { 'tomcat7078-sample.war':
        catalina_base => '/opt/tomcat7078-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat7078-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat7078-first':
        catalina_home  => '/opt/apache-tomcat7078',
        catalina_base  => '/opt/tomcat7078-first',
        service_ensure => 'running',
      }->
      tomcat::war { 'tomcat7-sample.war':
        catalina_base => '/opt/tomcat7-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat7-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat7-first':
        catalina_home  => '/opt/apache-tomcat7',
        catalina_base  => '/opt/tomcat7-first',
        service_ensure => 'running',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'tomcat7-first should not display message when war is not deployed', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8280/tomcat7-sample/hello.jsp') do |r|
        expect(r.stdout).not_to match(%r{Sample Application JSP Page})
      end
    end
    it 'tomcat7078-first should not display message when war is not deployed', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8380/tomcat7078-sample/hello.jsp') do |r|
        expect(r.stdout).not_to match(%r{Sample Application JSP Page})
      end
    end
  end

  context 'deploy the war' do
    pp = <<-MANIFEST
      tomcat::war { 'tomcat7-sample.war':
        catalina_base  => '/opt/tomcat7-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7-sample.war',
        war_ensure     => 'present',
        allow_insecure => true,
      } ~>
      tomcat::service { 'tomcat7-first':
        catalina_home  => '/opt/apache-tomcat7',
        catalina_base  => '/opt/tomcat7-first',
        service_ensure => 'running',
      }
      tomcat::war { 'tomcat7078-sample.war':
        catalina_base  => '/opt/tomcat7078-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat7078-sample.war',
        war_ensure     => 'present',
        allow_insecure => true,
      } ~>
      tomcat::service { 'tomcat7078-first':
        catalina_home  => '/opt/apache-tomcat7078',
        catalina_base  => '/opt/tomcat7078-first',
        service_ensure => 'running',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
    it 'tomcat7 should be serving a war on port 8280', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8280/tomcat7-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
    it 'tomcat7078 should be serving a war on port 8380', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8380/tomcat7078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
  end
end
