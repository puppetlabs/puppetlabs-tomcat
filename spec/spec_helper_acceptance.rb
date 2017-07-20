require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

def latest_tomcat_tarball_url(version)
  require 'net/http'
  page = Net::HTTP.get(URI("http://tomcat.apache.org/download-#{version}0.cgi"))
  if url = (match = page.match(%r{https?://.*?apache-tomcat-(.{4,7}).tar.gz}) and match[0])
    url
  else
    mirror_url = (match = page.match(%r{<strong>(https?://.*?)/</strong>}) and match[1])
    page = Net::HTTP.get(URI("#{mirror_url}/tomcat/tomcat-#{version}/"))
    latest_version = (match = page.match(%r{href="v(.{4,7})/"}) and match[1])

    "#{mirror_url}/tomcat/tomcat-#{version}/v#{latest_version}/bin/apache-tomcat-#{latest_version}.tar.gz"
  end
end

if ENV['BUILD_ID'] # We're in our CI system and use internal resources
  ARTIFACT_HOST = ENV['TOMCAT_ARTIFACT_HOST'] || 'http://int-resources.corp.puppetlabs.net/QA_resources/tomcat'

  TOMCAT6_RECENT_VERSION = ENV['TOMCAT6_RECENT_VERSION'] || 'latest6'
  TOMCAT6_RECENT_SOURCE = "#{ARTIFACT_HOST}/apache-tomcat-#{TOMCAT6_RECENT_VERSION}.tar.gz"
  TOMCAT7_RECENT_VERSION = ENV['TOMCAT7_RECENT_VERSION'] || 'latest7'
  TOMCAT7_RECENT_SOURCE = "#{ARTIFACT_HOST}/apache-tomcat-#{TOMCAT7_RECENT_VERSION}.tar.gz"
  TOMCAT8_RECENT_VERSION = ENV['TOMCAT8_RECENT_VERSION'] || 'latest8'
  TOMCAT8_RECENT_SOURCE = "#{ARTIFACT_HOST}/apache-tomcat-#{TOMCAT8_RECENT_VERSION}.tar.gz"
  TOMCAT_LEGACY_VERSION = ENV['TOMCAT_RECENT_VERSION'] || '6.0.39'
  TOMCAT_LEGACY_SOURCE = "#{ARTIFACT_HOST}/apache-tomcat-#{TOMCAT_LEGACY_VERSION}.tar.gz"
  SAMPLE_WAR = "#{ARTIFACT_HOST}/sample.war"

else # We're outside the CI system and use default locations
  require 'net/http'
  latest6 = latest_tomcat_tarball_url('6')
  latest7 = latest_tomcat_tarball_url('7')
  latest8 = latest_tomcat_tarball_url('8')

  TOMCAT6_RECENT_VERSION = ENV['TOMCAT6_RECENT_VERSION'] || latest6
  TOMCAT6_RECENT_SOURCE = latest6
  puts "TOMCAT6_RECENT_SOURCE is #{TOMCAT6_RECENT_SOURCE.inspect}"
  TOMCAT7_RECENT_VERSION = ENV['TOMCAT7_RECENT_VERSION'] || latest7
  TOMCAT7_RECENT_SOURCE = latest7
  puts "TOMCAT7_RECENT_SOURCE is #{TOMCAT7_RECENT_SOURCE.inspect}"
  TOMCAT8_RECENT_VERSION = ENV['TOMCAT8_RECENT_VERSION'] || latest8
  TOMCAT8_RECENT_SOURCE = latest8
  puts "TOMCAT8_RECENT_SOURCE is #{TOMCAT8_RECENT_SOURCE.inspect}"
  TOMCAT_LEGACY_VERSION = ENV['TOMCAT_LEGACY_VERSION'] || '6.0.39'
  TOMCAT_LEGACY_SOURCE = "http://archive.apache.org/dist/tomcat/tomcat-6/v#{TOMCAT_LEGACY_VERSION}/bin/apache-tomcat-#{TOMCAT_LEGACY_VERSION}.tar.gz"
  SAMPLE_WAR = 'https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war'
end


UNSUPPORTED_PLATFORMS = ['windows','Solaris','Darwin']


RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true

  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'tomcat')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib','--force','--version','4.6.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-java'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-gcc'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppet-archive'), { :acceptable_exit_codes => [0,1] }
      if fact('osfamily') == 'RedHat'
        on host, 'yum install -y nss'
      end
    end
  end
end
