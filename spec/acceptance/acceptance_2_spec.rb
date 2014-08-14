require 'spec_helper_acceptance'

stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up}

describe 'Acceptance case one - package install w/ init', :unless => stop_test do

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      class { 'java':}
      class { 'epel':}

      tomcat::instance{ 'tomcat_two':
        package => 'tomcat',
        catalina_base => '/opt/apache-tomcat/tomcat_two',
      }->
      tomcat::config::server{ 'tomcat_two':
        port => 8081,
        catalina_base => '/opt/apache-tomcat/tomcat_two',
      }->
      tomcat::config::server::connector{'tomcat_two':
        catalina_base => '/opt/apache-tomcat/tomcat_two',
        port => '8081',
        protocol => 'HTTP/1.1',
      }->
      tomcat::war { 'tomcat_two_war':
        war_source => '/opt/apache-tomcat/tomcat_two/webapps/docs/appdev/sample/sample.war',
        catalina_base => '/opt/apache-tomcat/tomcat_two',
        war_ensure => 'absent',
      }->
      tomcat::service { 'tomcat_two':
        catalina_base => '/opt/apache-tomcat/tomcat_two',
        use_init => true,
        service_ensure => true,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    # test the server
    it 'Should be serving a page on port 8081' do
      shell("/usr/bin/curl localhost:8081", {:acceptable_exit_codes => 0}) do |r|
        wait_for(r.stdout).to match(/Apache Tomcat/)
      end
    end
    #test the war
    it 'Should not be serving a page on port 8081 from the war' do
      shell("/usr/bin/curl localhost:8081/sample/hello.jsp", :acceptable_exit_codes => 7) do |r|
        wait_for(r.stdout).to match(/The requested resource is not available/)
      end
    end
  end

  context 'Stop tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::service { 'tomcat_two':
        catalina_base => '/opt/apache-tomcat/tomcat_two',
        use_init => true,
        service_ensure => 'stopped',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'Should not be serving a page on port 8081' do
      shell("/usr/bin/curl localhost:8081", :acceptable_exit_codes => 7) do |r|
        wait_for(r.stdout).to match(/404/)
      end
    end
  end

  context 'Start Tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::service { 'tomcat_two':
        catalina_base => '/opt/apache-tomcat/tomcat_two',
        use_init => true,
        service_ensure => 'running',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'Should be serving a page on port 8081' do
      shell("/usr/bin/curl localhost:8081", {:acceptable_exit_codes => 0}) do |r|
        wait_for(r.stdout).to match(/Apache Tomcat/)
      end
    end
  end

  context 'deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::war { 'tomcat_two_war':
        war_ensure => 'present',
        catalina_base => '/opt/apache-tomcat/tomcat_two',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should be serving a localhost:8081/sample/hello.jsp', {:acceptable_exit_codes => 0}) do |r|
        wait_for(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
  end

  context 'un-deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::war { 'tomcat_two_war':
        war_ensure => false,
        catalina_base => '/opt/apache-tomcat/tomcat_two',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'Should not have deployed the war' do
      shell('/usr/bin/curl localhost:8081/sample.war', {:acceptable_exit_codes => 7}) do |r|
        wait_for(r.stdout).to match(/The requested resource is not available/)
      end
    end
  end

end








