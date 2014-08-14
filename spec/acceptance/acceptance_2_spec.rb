require 'spec_helper_acceptance'

describe 'Acceptance case one - package install w/ init' do

  #confine is broken :()
  #confine(:except, 'windows')

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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    # test the server
    it 'Should be serving a page on port 8081' do
      shell("/usr/bin/curl localhost:8081/server_????", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TOMCAT STUFF/)
      end
    end
    #test the war
    it 'Should not be serving a page on port 8081' do
      expect(shell("/usr/bin/curl localhost:8081/sample/hello.jsp")).exit_code.should be(7)
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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not be serving a page on port 8081' do
      expect(shell("/usr/bin/curl localhost:8081/server????").exit_code).to be(7)
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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should be serving a page on port 8081' do
      shell("/usr/bin/curl localhost:8081/server????", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TOMCAT STUFF/)
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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'should be serving a page on port 8081' do
      shell('/usr/bin/curl localhost:8081/sample.jsp', {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TomCAT STUFF/)
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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not have deployed the war' do
      expect(shell('/usr/bin/curl localhost:8081/sample.war', {:acceptable_exit_codes => 0}).exit_code).to be(7)
    end
  end

end








