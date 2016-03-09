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
        source_url => 'http://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz',
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
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 7)
    end
  end

  context 'Start Tomcat with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      $java_home = $::osfamily ? {
        'RedHat' => '/etc/alternatives/java_sdk',
        'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
        default  => undef
      }

      tomcat::service { 'jsvc-default':
        service_ensure => running,
        catalina_home  => '/opt/apache-tomcat',
        catalina_base  => '/opt/apache-tomcat/tomcat8-jsvc',
        use_jsvc       => true,
        java_home      => $java_home,
        user           => 'tomcat8',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'un-deploy the war with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::war { 'war_one.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source    => '#{SAMPLE_WAR}',
        war_ensure    => absent,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not have deployed the war' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should eq("")
      end
    end
  end

  context 'remove the connector with verification' do

    it 'Should apply the manifest without error' do
      pp = <<-EOS
      $java_home = $::osfamily ? {
        'RedHat' => '/etc/alternatives/java_sdk',
        'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
        default  => undef
      }

      tomcat::config::server::connector { 'tomcat8-jsvc':
        connector_ensure => 'absent',
        catalina_base    => '/opt/apache-tomcat/tomcat8-jsvc',
        port             => '80',
        notify           => Tomcat::Service['jsvc-default']
      }
      tomcat::service { 'jsvc-default':
        service_ensure => running,
        catalina_home  => '/opt/apache-tomcat',
        catalina_base  => '/opt/apache-tomcat/tomcat8-jsvc',
        java_home      => $java_home,
        use_jsvc       => true,
        user           => 'tomcat8',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be able to serve pages over port 80' do
      shell('curl localhost:80', :acceptable_exit_codes => 7)
    end
  end
end
