require 'spec_helper_acceptance'

describe 'tomcat class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'happy path, multiple instances' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'tomcat': }
      class { 'java': }

      tomcat::instance { 'tomcat8':
        catalina_base => '/opt/apache-tomcat/tomcat8',
        source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
      }->
      tomcat::war { 'sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat8',
        war_source => '/opt/apache-tomcat/tomcat8/webapps/docs/appdev/sample/sample.war',
      }->
      tomcat::service { 'default':
        catalina_base => '/opt/apache-tomcat/tomcat8',
      }

      tomcat::instance { 'tomcat6':
        source_url => 'http://apache.mirror.quintex.com/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz',
        catalina_base => '/opt/apache-tomcat/tomcat6',
      }->
      tomcat::config::server { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        port          => '8105',
      }->
      tomcat::config::server::connector { 'tomcat6-http':
        catalina_base         => '/opt/apache-tomcat/tomcat6',
        port                  => '8180',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }->
      tomcat::config::server::connector { 'tomcat6-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat6',
        port                  => '8109',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }->
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_source    => '/opt/apache-tomcat/tomcat6/webapps/docs/appdev/sample/sample.war',
        war_name      => 'sample.war',
      }->
      tomcat::service { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6'
      }

      tomcat::instance { 'tomcat7':
        source_url => 'http://www.carfab.com/apachesoftware/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54.tar.gz',
        catalina_base => '/opt/apache-tomcat/tomcat7',
      }->
      tomcat::config::server { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        port          => '8205',
      }->
      tomcat::config::server::connector { 'tomcat7-http':
        catalina_base         => '/opt/apache-tomcat/tomcat7',
        port                  => '8280',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }->
      tomcat::config::server::connector { 'tomcat7-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat7',
        port                  => '8209',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }->
      tomcat::war { 'tomcat7-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        war_name      => 'sample.war',
        war_source    => '/opt/apache-tomcat/tomcat7/webapps/docs/appdev/sample/sample.war',
      }->
      tomcat::service { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failues => true).exit_code).to be_zero
    end

  end
end
