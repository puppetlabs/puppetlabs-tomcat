require 'spec_helper_acceptance'

describe 'tomcat class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'happy path, multiple instances' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'tomcat': }
      class { 'java': }

      if ($::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04') or ($::osfamily == 'RedHat' and $::operatingsystemmajrelease == '5') {
        tomcat::instance { 'tomcat7-default':
          catalina_base => '/opt/apache-tomcat/tomcat7-default',
          source_url => 'http://www.dsgnwrld.com/am/tomcat/tomcat-7/v7.0.55/bin/apache-tomcat-7.0.55.tar.gz'
        }->
        tomcat::config::server::connector { 'tomcat7-default-http':
          catalina_base         => '/opt/apache-tomcat/tomcat7-default',
          port                  => '8082',
          protocol              => 'HTTP/1.1',
        }->
        tomcat::war { 'sample.war':
          catalina_base => '/opt/apache-tomcat/tomcat7-default',
          war_source => '/opt/apache-tomcat/tomcat7-default/webapps/docs/appdev/sample/sample.war',
        }->
        tomcat::service { 'default':
          catalina_base => '/opt/apache-tomcat/tomcat7-default',
        }
      } else {
        tomcat::instance { 'tomcat8':
          catalina_base => '/opt/apache-tomcat/tomcat8',
          source_url => 'http://apache.mirrors.hoobly.com/tomcat/tomcat-8/v8.0.9/bin/apache-tomcat-8.0.9.tar.gz'
        }->
        tomcat::war { 'sample.war':
          catalina_base => '/opt/apache-tomcat/tomcat8',
          war_source => '/opt/apache-tomcat/tomcat8/webapps/docs/appdev/sample/sample.war',
        }->
        tomcat::config::server::connector { 'tomcat7-default-http':
          catalina_base         => '/opt/apache-tomcat/tomcat8',
          port                  => '8082',
          protocol              => 'HTTP/1.1',
        }->
        tomcat::service { 'default':
          catalina_base => '/opt/apache-tomcat/tomcat8',
        }
      }

      tomcat::instance { 'tomcat6':
        source_url => 'http://mirror.symnds.com/software/Apache/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz',
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
        source_url => 'http://www.dsgnwrld.com/am/tomcat/tomcat-7/v7.0.55/bin/apache-tomcat-7.0.55.tar.gz',
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
      # give tomcat time to start and deploy things
      shell("sleep 10")
    end
    it 'should have deployed the sample JSP on 8082' do
      shell("/usr/bin/curl localhost:8082/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8082' do
      shell("/usr/bin/curl localhost:8082/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should have deployed the sample JSP on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should have deployed the sample JSP on 8280' do
      shell("/usr/bin/curl localhost:8280/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8280' do
      shell("/usr/bin/curl localhost:8280/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should be able to stop an instance' do
      pp = <<-EOS
      class { 'tomcat': }
      class { 'java': }

      if ($::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04') or ($::osfamily == 'RedHat' and $::operatingsystemmajrelease == '5') {
        tomcat::service { 'default':
          catalina_base  => '/opt/apache-tomcat/tomcat7-default',
          service_ensure => stopped,
        }
      } else {
        tomcat::service { 'default':
          catalina_base  => '/opt/apache-tomcat/tomcat8',
          service_ensure => stopped,
        }
      }
      tomcat::service { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        service_ensure => stopped,
      }
      tomcat::war { 'tomcat6-sample2.war':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_source    => '/opt/apache-tomcat/tomcat6/webapps/docs/appdev/sample/sample.war',
        war_name      => 'sample2.war',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failues => true).exit_code).to be_zero
      # give tomcat time to stop and deploy the new WAR
      shell("sleep 10")
    end
    it 'should not have deployed the sample JSP on 8082' do
      shell("/usr/bin/curl localhost:8082/sample/hello.jsp", {:acceptable_exit_codes => 7})
    end
    it 'should not have deployed the sample servlet on 8082' do
      shell("/usr/bin/curl localhost:8082/sample/hello", {:acceptable_exit_codes => 7})
    end
    it 'should have deployed the sample JSP on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should have deployed the sample JSP on 8180 again' do
      shell("/usr/bin/curl localhost:8180/sample2/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8180 again' do
      shell("/usr/bin/curl localhost:8180/sample2/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should not have deployed the sample JSP on 8280' do
      shell("/usr/bin/curl localhost:8280/sample/hello.jsp", {:acceptable_exit_codes => 7})
    end
    it 'should not have deployed the sample servlet on 8280' do
      shell("/usr/bin/curl localhost:8280/sample/hello", {:acceptable_exit_codes => 7})
    end
    it 'should be able to undeploy a WAR' do
      pp = <<-EOS
      tomcat::war { 'tomcat6-sample2.war':
        war_ensure    => 'absent',
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_name      => 'sample2.war',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failues => true).exit_code).to be_zero
      # give tomcat time to undeploy the WAR
      shell("sleep 10")
    end
    it 'should have deployed the sample JSP on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8180' do
      shell("/usr/bin/curl localhost:8180/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should have removed the sample JSP on 8180' do
      shell("/usr/bin/curl localhost:8180/sample2/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/HTTP Status 404/)
      end
    end
    it 'should have removed the sample servlet on 8180' do
      shell("/usr/bin/curl localhost:8180/sample2/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/HTTP Status 404/)
      end
    end
    it 'should be able to run with jsvc on port below 1024', :unless => ((fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04') or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5')) do
      pp = <<-EOS
      class { 'tomcat': }
      class { 'gcc': }
      class { 'java': }

      $java_home = $::osfamily ? {
        'RedHat' => '/etc/alternatives/java_sdk',
        'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
        default  => undef
      }

      tomcat::instance { 'test':
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
      }->
      tomcat::war { 'sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source => '/opt/apache-tomcat/tomcat8-jsvc/webapps/docs/appdev/sample/sample.war',
      }->
      tomcat::setenv::entry { 'JAVA_HOME':
        base_path => '/opt/apache-tomcat/tomcat8-jsvc/bin',
        value     => $java_home,
      }->
      tomcat::service { 'jsvc-default':
          catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
          java_home     => $java_home,
          use_jsvc      => true,
      }
      tomcat::service { 'tomcat8-default':
          catalina_base => '/opt/apache-tomcat/tomcat8',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failues => true).exit_code).to be_zero
      #give tomcat time to start up
      shell("sleep 10")
    end
    it 'should have deployed the sample JSP on 8082', :unless => ((fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04') or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5')) do
      shell("/usr/bin/curl localhost:8082/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 8082', :unless => ((fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04') or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5')) do
      shell("/usr/bin/curl localhost:8082/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
    it 'should have deployed the sample JSP on 80', :unless => ((fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04') or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5')) do
      shell("/usr/bin/curl localhost:80/sample/hello.jsp", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'should have deployed the sample servlet on 80', :unless => ((fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') == '10.04') or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5')) do
      shell("/usr/bin/curl localhost:80/sample/hello", {:acceptable_exit_codes => 0}) do |r|
        r.stdout.should match(/Sample Application Servlet Page/)
      end
    end
  end
end
