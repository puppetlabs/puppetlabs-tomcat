require 'spec_helper_acceptance'

#fact based two stage confine

#confine array
confine_array = [
  (fact('operatingsystem') == 'Ubuntu'  &&  fact('operatingsystemrelease') == '10.04'),
  (fact('osfamily') == 'RedHat'         &&  fact('operatingsystemmajrelease') == '5'),
  (fact('operatingsystem') == 'Debian'  &&  fact('operatingsystemmajrelease') == '6'),
  fact('osfamily') == 'Suse'
]

stop_test = false
stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up} || confine_array.any?

describe 'README examples', :unless => stop_test do
  after :all do
    shell('pkill -f tomcat', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/tomcat*', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/apache-tomcat*', :acceptable_exit_codes => [0,1])
  end

  context 'Beginning with Tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{'java':}
      tomcat::install { '/opt/tomcat':
        source_url => '#{TOMCAT8_RECENT_SOURCE}',
      }
      tomcat::instance { 'default':
        catalina_home => '/opt/tomcat',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
      shell('sleep 15')
    end
    it 'has the server running on port 8080' do
      shell('curl localhost:8080', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
  end

  context 'I want to run multiple instances of multiple versions of tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'java': }

      tomcat::install { '/opt/tomcat9':
        source_url => '#{TOMCAT9_RECENT_SOURCE}'
      }
      tomcat::instance { 'tomcat9-first':
        catalina_home => '/opt/tomcat9',
        catalina_base => '/opt/tomcat9/first',
      }
      tomcat::instance { 'tomcat9-second':
        catalina_home => '/opt/tomcat9',
        catalina_base => '/opt/tomcat9/second',
      }
      # Change the default port of the second instance server and HTTP connector
      tomcat::config::server { 'tomcat9-second':
        catalina_base => '/opt/tomcat9/second',
        port          => '8006',
      }
      tomcat::config::server::connector { 'tomcat9-second-http':
        catalina_base         => '/opt/tomcat9/second',
        port                  => '8081',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8443'
        },
      }

      tomcat::install { '/opt/tomcat7':
        source_url => '#{TOMCAT7_RECENT_SOURCE}',
      }
      tomcat::instance { 'tomcat7':
        catalina_home => '/opt/tomcat7',
      }
      # Change tomcat 7's server and HTTP/AJP connectors
      tomcat::config::server { 'tomcat7':
        catalina_base => '/opt/tomcat7',
        port          => '8105',
      }
      tomcat::config::server::connector { 'tomcat7-http':
        catalina_base         => '/opt/tomcat7',
        port                  => '8180',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      tomcat::config::server::connector { 'tomcat7-ajp':
        catalina_base         => '/opt/tomcat7',
        port                  => '8109',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 7)
    end
  end
end
