require 'spec_helper_acceptance'

stop_test = (UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up} || SKIP_TOMCAT_8)

describe 'Use two realms within a configuration', docker: true, :unless => stop_test do
  after :all do
    shell('pkill -f tomcat', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/tomcat*', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/apache-tomcat*', :acceptable_exit_codes => [0,1])
  end

  before :all do
    shell("curl -k -o /tmp/sample.war '#{SAMPLE_WAR}'", :acceptable_exit_codes => 0)
  end

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'java':}
      class { 'tomcat': catalina_home => '/opt/apache-tomcat40', }
      tomcat::install { '/opt/apache-tomcat40':
        source_url     => '#{TOMCAT8_RECENT_SOURCE}',
        allow_insecure => true,
      }
      tomcat::instance { 'tomcat40':}
      tomcat::config::server { 'tomcat40':
        catalina_base => '/opt/apache-tomcat40',
        port          => '8105',
      }
      tomcat::config::server::connector { 'tomcat40-http':
        catalina_base         => '/opt/apache-tomcat40',
        port                  => '8180',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      tomcat::config::server::connector { 'tomcat40-ajp':
        catalina_base         => '/opt/apache-tomcat40',
        port                  => '8109',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      tomcat::war { 'tomcat40-sample.war':
        catalina_base  => '/opt/apache-tomcat40',
        war_source     => '/tmp/sample.war',
        war_name       => 'tomcat40-sample.war',
        allow_insecure => true,
      }
      tomcat::config::server::realm { 'org.apache.catalina.realm.CombinedRealm':
        catalina_base => '/opt/apache-tomcat40',
      }
      tomcat::config::server::realm { 'org.apache.catalina.realm.MyRealm1':
        realm_ensure          => present,
        catalina_base         => '/opt/apache-tomcat40',
        parent_realm          => 'org.apache.catalina.realm.CombinedRealm',
        class_name            => 'org.apache.catalina.realm.MyRealm',
        server_config         => '/opt/apache-tomcat40/conf/server.xml',
        additional_attributes => {
          resourceName   => "MyRealm1",
          otherAttribute => "more stuff",
        }
      }
      tomcat::config::server::realm { 'org.apache.catalina.realm.MyRealm2':
        realm_ensure          => present,
        catalina_base         => '/opt/apache-tomcat40',
        parent_realm          => 'org.apache.catalina.realm.CombinedRealm',
        class_name            => 'org.apache.catalina.realm.MyRealm',
        server_config         => '/opt/apache-tomcat40/conf/server.xml',
        additional_attributes => {
          resourceName   => "MyRealm2",
          otherAttribute => "more stuff",
        }
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'Should contain two realms in config file', :retry => 5, :retry_wait => 10 do
      shell('cat /opt/apache-tomcat40/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/<Realm puppetName="org.apache.catalina.realm.MyRealm1" className="org.apache.catalina.realm.MyRealm" resourceName="MyRealm1" otherAttribute="more stuff"><\/Realm>/)
        r.stdout.should match(/<Realm puppetName="org.apache.catalina.realm.MyRealm2" className="org.apache.catalina.realm.MyRealm" resourceName="MyRealm2" otherAttribute="more stuff"><\/Realm>/)
      end
    end
    it 'should be idempotent' do
      pp = <<-EOS
      tomcat::config::server::realm { 'org.apache.catalina.realm.CombinedRealm':
        catalina_base => '/opt/apache-tomcat40',
      }
      tomcat::config::server::realm { 'org.apache.catalina.realm.MyRealm1':
        realm_ensure          => present,
        catalina_base         => '/opt/apache-tomcat40',
        parent_realm          => 'org.apache.catalina.realm.CombinedRealm',
        class_name            => 'org.apache.catalina.realm.MyRealm',
        server_config         => '/opt/apache-tomcat40/conf/server.xml',
        additional_attributes => {
          resourceName   => "MyRealm1",
          otherAttribute => "more stuff",
        }
      }
      tomcat::config::server::realm { 'org.apache.catalina.realm.MyRealm2':
        realm_ensure          => present,
        catalina_base         => '/opt/apache-tomcat40',
        parent_realm          => 'org.apache.catalina.realm.CombinedRealm',
        class_name            => 'org.apache.catalina.realm.MyRealm',
        server_config         => '/opt/apache-tomcat40/conf/server.xml',
        additional_attributes => {
          resourceName   => "MyRealm2",
          otherAttribute => "more stuff",
        }
      }
      EOS
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
