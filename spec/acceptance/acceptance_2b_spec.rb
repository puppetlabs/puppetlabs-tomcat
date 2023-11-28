# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Two different installations with two instances each of Tomcat 8 in the same manifest', :docker do
  after :all do
    run_shell('pkill -f tomcat', expect_failures: true)
    run_shell('rm -rf /opt/tomcat*', expect_failures: true)
    run_shell('rm -rf /opt/apache-tomcat*', expect_failures: true)
  end

  context 'Initial install Tomcat and verification' do
    pp = <<-MANIFEST
      class { 'java':}
      tomcat::install { 'tomcat8':
        catalina_home  => '/opt/apache-tomcat8',
        source_url     => '#{TOMCAT8_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat8-first':
        catalina_home => '/opt/apache-tomcat8',
        catalina_base => '/opt/tomcat8-first',
      }
      tomcat::instance { 'tomcat8-second':
        catalina_home => '/opt/apache-tomcat8',
        catalina_base => '/opt/tomcat8-second',
      }
      tomcat::config::server { 'tomcat8-first':
        catalina_base => '/opt/tomcat8-first',
        port          => '8205',
      }
      tomcat::config::server { 'tomcat8-second':
        catalina_base => '/opt/tomcat8-second',
        port          => '8206',
      }
      tomcat::config::server::connector { 'tomcat8-first-http':
        catalina_base         => '/opt/tomcat8-first',
        port                  => '8280',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat8-first-ajp':
        catalina_base         => '/opt/tomcat8-first',
        port                  => '8209',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat8-second-http':
        catalina_base         => '/opt/tomcat8-second',
        port                  => '8281',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::config::server::connector { 'tomcat8-second-ajp':
        catalina_base         => '/opt/tomcat8-second',
        port                  => '8210',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::war { 'first tomcat8-sample.war':
        catalina_base  => '/opt/tomcat8-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8#sample.war',
        allow_insecure => true,
      }
      tomcat::war { 'second tomcat8-sample.war':
        catalina_base  => '/opt/tomcat8-second',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8#sample.war',
        allow_insecure => true,
      }


      tomcat::install { 'tomcat8078':
        catalina_home  => '/opt/apache-tomcat8078',
        source_url     => '#{TOMCAT8_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat8078-first':
        catalina_home => '/opt/apache-tomcat8078',
        catalina_base => '/opt/tomcat8078-first',
      }
      tomcat::instance { 'tomcat8078-second':
        catalina_home => '/opt/apache-tomcat8078',
        catalina_base => '/opt/tomcat8078-second',
      }
      tomcat::config::server { 'tomcat8078-first':
        catalina_base => '/opt/tomcat8078-first',
        port          => '8305',
      }
      tomcat::config::server { 'tomcat8078-second':
        catalina_base => '/opt/tomcat8078-second',
        port          => '8306',
      }
      tomcat::config::server::connector { 'tomcat8078-first-http':
        catalina_base         => '/opt/tomcat8078-first',
        port                  => '8380',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat8078-second-http':
        catalina_base         => '/opt/tomcat8078-second',
        port                  => '8381',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::config::server::connector { 'tomcat8078-first-ajp':
        catalina_base         => '/opt/tomcat8078-first',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat8078-second-ajp':
        catalina_base         => '/opt/tomcat8078-second',
        port                  => '8310',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::war { 'first tomcat8078-sample.war':
        catalina_base  => '/opt/tomcat8078-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8078-sample.war',
        allow_insecure => true,
      }
      tomcat::war { 'second tomcat8078-sample.war':
        catalina_base  => '/opt/tomcat8078-second',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8078-sample.war',
        allow_insecure => true,
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp)
    end

    # test the war
    it 'tomcat8-first should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8280/tomcat8/sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end

    it 'tomcat8-second should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8281/tomcat8/sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end

    it 'tomcat8078-first should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8380/tomcat8078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end

    it 'tomcat8078-second should have war deployed by default', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8381/tomcat8078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
  end

  context 'Stop tomcat service' do
    pp = <<-MANIFEST
      tomcat::service { 'tomcat8-first':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/tomcat8-first',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat8-second':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/tomcat8-second',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat8078-first':
        catalina_home  => '/opt/apache-tomcat8078',
        catalina_base  => '/opt/tomcat8078-first',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat8078-second':
        catalina_home  => '/opt/apache-tomcat8078',
        catalina_base  => '/opt/tomcat8078-second',
        service_ensure => 'stopped',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end

    it 'tomcat8-first should not be serving a page on port 8280', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8280', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end

    it 'tomcat8-second should not be serving a page on port 8281', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8281', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end

    it 'tomcat8078-first should not be serving a page on port 8380', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8380', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end

    it 'tomcat8078-second should not be serving a page on port 8381', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8381', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
  end

  context 'Start Tomcat without war' do
    pp = <<-MANIFEST
      tomcat::war { 'tomcat8078-sample.war':
        catalina_base => '/opt/tomcat8078-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat8078-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat8078-first':
        catalina_home  => '/opt/apache-tomcat8078',
        catalina_base  => '/opt/tomcat8078-first',
        service_ensure => 'running',
      }->
      tomcat::war { 'tomcat8-sample.war':
        catalina_base => '/opt/tomcat8-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat8-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat8-first':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/tomcat8-first',
        service_ensure => 'running',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end

    it 'tomcat8-first should not display message when war is not deployed', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8280/tomcat8-sample/hello.jsp') do |r|
        expect(r.stdout).not_to match(%r{Sample Application JSP Page})
      end
    end

    it 'tomcat8078-first should not display message when war is not deployed', retry: 10, retry_wait: 10 do
      run_shell('curl localhost:8380/tomcat8078-sample/hello.jsp') do |r|
        expect(r.stdout).not_to match(%r{Sample Application JSP Page})
      end
    end
  end

  context 'deploy the war' do
    pp = <<-MANIFEST
      tomcat::war { 'tomcat8-sample.war':
        catalina_base  => '/opt/tomcat8-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8-sample.war',
        war_ensure     => 'present',
        allow_insecure => true,
      } ~>
      tomcat::service { 'tomcat8-first':
        catalina_home  => '/opt/apache-tomcat8',
        catalina_base  => '/opt/tomcat8-first',
        service_ensure => 'running',
      }
      tomcat::war { 'tomcat8078-sample.war':
        catalina_base  => '/opt/tomcat8078-first',
        war_source     => '#{SAMPLE_WAR}',
        war_name       => 'tomcat8078-sample.war',
        war_ensure     => 'present',
        allow_insecure => true,
      } ~>
      tomcat::service { 'tomcat8078-first':
        catalina_home  => '/opt/apache-tomcat8078',
        catalina_base  => '/opt/tomcat8078-first',
        service_ensure => 'running',
      }
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end

    it 'tomcat8 should be serving a war on port 8280', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8280/tomcat8-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end

    it 'tomcat8078 should be serving a war on port 8380', retry: 10, retry_wait: 10 do
      run_shell('curl --retry 10 --retry-delay 15 localhost:8380/tomcat8078-sample/hello.jsp') do |r|
        expect(r.stdout).to match(%r{Sample Application JSP Page})
      end
    end
  end
end
