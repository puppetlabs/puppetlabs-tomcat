# frozen_string_literal: true

require 'spec_helper_acceptance'

confine_array = [
  (os[:family] =~ %r{debian|ubuntu} &&  (os[:release] == '16.04' || os[:release] == '18.04' || os[:release] == '8')),
  (os[:family].include?('redhat')   &&  os[:release].start_with?('5')),
]
stop_test = confine_array.any?

describe 'README examples', unless: stop_test do
  after :all do
    run_shell('pkill -f tomcat', expect_failures: true)
    run_shell('rm -rf /opt/tomcat*', expect_failures: true)
    run_shell('rm -rf /opt/apache-tomcat*', expect_failures: true)
  end

  context 'Beginning with Tomcat' do
    pp = <<-MANIFEST
      class{'java':}
      tomcat::install { '/opt/tomcat':
        source_url => '#{TOMCAT8_RECENT_SOURCE}',
      }
      tomcat::instance { 'default':
        catalina_home => '/opt/tomcat',
      }
    MANIFEST
    it 'applies the manifest without error' do
      idempotent_apply(pp)
      run_shell('sleep 15')
    end
    it 'has the server running on port 8080' do
      run_shell('curl localhost:8080') do |r|
        expect(r.stdout).to match(%r{Apache Tomcat})
      end
    end
  end

  context 'I want to run multiple instances of multiple versions of tomcat' do
    pp = <<-MANIFEST
      class { 'java': }

      tomcat::install { '/opt/tomcat9':
        source_url => '#{TOMCAT9_RECENT_SOURCE}',
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
    MANIFEST
    it 'applies the manifest without error' do
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
      run_shell('sleep 15')
    end
    it 'is not serving a page on port 80' do
      run_shell('curl localhost:80/war_one/hello.jsp', expect_failures: true) do |r|
        expect(r.exit_code).to eq 7
      end
    end
  end

  describe 'remove webapps built-in files' do
    after :each do
      run_shell('pkill -f tomcat', expect_failures: true)
      run_shell('rm -rf /opt/tomcat*', expect_failures: true)
      run_shell('rm -rf /opt/apache-tomcat*', expect_failures: true)
    end
    { '7' => TOMCAT7_RECENT_SOURCE, '8' => TOMCAT8_RECENT_SOURCE, '9' => TOMCAT9_RECENT_SOURCE }.each do |key, value|
      context "when tomcat #{key} is installed remove_default_webapps => ['docs', 'examples']" do
        install_tomcat = <<-MANIFEST
        tomcat::install { '/opt/tomcat#{key}':
          source_url => '#{value}',
          remove_default_webapps => ['docs', 'examples'],
        }
        MANIFEST
        it 'webapps should not contain the removed folder' do
          apply_manifest(install_tomcat, catch_failures: true)
          run_shell("ls -l /opt/tomcat#{key}/webapps") do |r|
            expect(r.stdout).not_to include('docs')
            expect(r.stdout).not_to include('examples')
          end
        end
      end
    end
  end
end
