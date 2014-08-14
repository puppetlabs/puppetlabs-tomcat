require 'spec_helper_acceptance'

before(:all) do
  #build a module and inject a war to serve from puppet:///

  #Test directory
  testdir = create_tmpdir_for_user(master, name = 'file_path')

  #Modules Init
  modules_dir = "/tmp/modules"
  source_files_dir = "#{modules_dir}/source_mod/files"

  #Master Configuration
  master_opts = {
    'master' => {
      'manifest' => remote_site_pp_path,
      'modulepath' => "/opt/puppet/share/puppet/modules:#{modules_dir}",
    }
  }
    #scp war file to host
    #acceptable exit codes???
    #TODO get sample war file
    #what directory is this file going to be run from
    scp_to(master, 'lib/sample.war', "#{source_files_dir}/sample.war")
end

# ALL DEFAULTS ALL THE TIME!!!!
describe 'Tomcat Install source -defaults' do

  confine(:except, UNSUPPORTED_PLATFORMS)

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::instance{'tomcat_three':
        source_url => 'http://mirror.symnds.com/software/Apache/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz',
        catalina_base => '/opt/apache-tomcat/tomcat_three',
      }->
      tomcat::config::server::connector{'tomcat_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        port => '8082',
        protocol => 'HTTP/1.1',
      }
      tomcat::war{'tomcat_war_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        war_source => 'puppet:///modules/source_mod/sample.war',
        war_ensure => true,
      }->
      tomcat::service{'tomcat_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should be serving a page on port 8082'
      shell("/usr/bin/curl localhost:8082/server", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TOMCAT STUFF/)
      end
    end
    it 'Should be serving a JSP page from the war'
      shell('/usr/bin/curl localhost:8082/sample/hello.jsp', {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TOMCAT STUFF/)
      end
    end
  end

  context 'Stop tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::service{'tomcat_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        service_ensure => 'stopped',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not be serving a page on port 8082' do
      expect(shell("/usr/bin/curl localhost:8082/server???").exit_code).to be(7)
    end
  end

  context 'Start Tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::service{'tomcat_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        service_ensure => 'running',
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should be serving a page on port 8082'
      shell("/usr/bin/curl localhost:8082/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/TOMCAT STUFF/)
      end
    end
  end

  context 'un-deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::war{'tomcat_war_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        war_source => 'puppet:///modules/source_mod/sample.war',
        war_ensure => false,
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not have deployed the war' do
      shell('/usr/bin/curl localhost:8082/sample.war', {:acceptable_exit_codes => 7}) do |r|
        r.stdout.should match(/OOPS YOUR WAR IS NOT HERE!!!/)
      end
    end
  end

  context 'remove the connector' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::config::server::connector{'tomcat_three':
        catalina_base => '/opt/apache-tomcat/tomcat_three',
        port => '8082',
        protocol => 'HTTP/1.1',
        connector_ensure => false,
      }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      # sleep to give Tomcat time to catch up
      sleep 10
    end
    it 'Should not be abble to serve pages over port 8082' do
      expect(shell("/usr/bin/curl localhost:8082/server???").exit_code).to be(7) #TODO test ????
    end
  end

end






