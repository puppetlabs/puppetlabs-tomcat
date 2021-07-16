# frozen_string_literal: true

require 'rspec/retry'
require 'singleton'
require 'serverspec'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.verbose_retry = true
  c.display_try_failure_messages = true

  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    LitmusHelper.instance.run_shell('puppet module install puppetlabs-gcc')
    LitmusHelper.instance.run_shell('puppet module install puppetlabs-java')
    if os[:family] == 'redhat' && os[:release].to_i != 8
      LitmusHelper.instance.run_shell('puppet module install stahnma/epel')
      pp = <<-PUPPETCODE
      # needed by tests
      package { 'curl':
        ensure   => 'latest',
      }
      if $::osfamily == 'RedHat' {
        if $::operatingsystemmajrelease == '5' {
          class { 'epel':
            epel_baseurl => "http://osmirror.delivery.puppetlabs.net/epel${::operatingsystemmajrelease}-\\$basearch/RPMS.all",
            epel_mirrorlist => "http://osmirror.delivery.puppetlabs.net/epel${::operatingsystemmajrelease}-\\$basearch/RPMS.all",
          }
        } else {
          class { 'epel': }
        }
      }
      PUPPETCODE
      LitmusHelper.instance.apply_manifest(pp)

      LitmusHelper.instance.run_shell('yum update -y')
      LitmusHelper.instance.run_shell('yum install -y crontabs tar wget openssl iproute which initscripts nss')
    elsif os[:family] == 'redhat' && os[:release].to_i == 8
      LitmusHelper.instance.run_shell('yum update -y')
      LitmusHelper.instance.run_shell('yum install make -y')
    elsif os[:family] == 'ubuntu'
      LitmusHelper.instance.run_shell('rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl', expect_failures: true)
      LitmusHelper.instance.run_shell('apt-get update', expect_failures: true)
      LitmusHelper.instance.run_shell('DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools curl wget', expect_failures: true)
      LitmusHelper.instance.run_shell('locale-gen en_US.UTF-8', expect_failures: true)
    elsif os[:family] == 'debian'
      LitmusHelper.instance.run_shell('apt-get update && apt-get install -y net-tools curl wget locales strace lsof && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen', expect_failures: true)
    end
  end
end

def latest_tomcat_tarball_url(version)
  require 'net/http'
  page = Net::HTTP.get(URI("https://tomcat.apache.org/download-#{version}0.cgi"))

  url = ((match = page.match(%r{https?://.*?apache-tomcat-(.{4,9}).tar.gz})) && match[0])
  return url if url

  mirror_url = ((match = page.match(%r{<strong>(https?://.*?)/</strong>})) && match[1])
  page = Net::HTTP.get(URI("#{mirror_url}/tomcat/tomcat-#{version}/"))
  latest_version = ((match = page.match(%r{href="v(.{4,9})/"})) && match[1])

  "#{mirror_url}/tomcat/tomcat-#{version}/v#{latest_version}/bin/apache-tomcat-#{latest_version}.tar.gz"
end

latest8 = latest_tomcat_tarball_url('8')
latest9 = latest_tomcat_tarball_url('9')
TOMCAT_LEGACY_VERSION = ENV['TOMCAT_LEGACY_VERSION'] || '7.0.85'
# Please note that these URLs are http and therefore insecure. To remedy this you can change them to https, although some additional work may be required to match the required protocols of the server.
TOMCAT7_RECENT_SOURCE = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{TOMCAT_LEGACY_VERSION}/bin/apache-tomcat-#{TOMCAT_LEGACY_VERSION}.tar.gz"
puts "TOMCAT7_RECENT_SOURCE is #{TOMCAT7_RECENT_SOURCE.inspect}"

TOMCAT8_RECENT_VERSION = ENV['TOMCAT8_RECENT_VERSION'] || latest8
TOMCAT8_RECENT_SOURCE = latest8
puts "TOMCAT8_RECENT_SOURCE is #{TOMCAT8_RECENT_SOURCE.inspect}"

TOMCAT9_RECENT_VERSION = ENV['TOMCAT9_RECENT_VERSION'] || latest9
TOMCAT9_RECENT_SOURCE = latest9
puts "TOMCAT9_RECENT_SOURCE is #{TOMCAT9_RECENT_SOURCE.inspect}"

SAMPLE_WAR = 'https://tomcat.apache.org/tomcat-9.0-doc/appdev/sample/sample.war'

confine_8_array = [
  (os[:family].include?('redhat') &&  os[:release].start_with?('5')),
  (os[:family].include?('suse')   &&  os[:release].start_with?('11')),
]

# Tomcat 8 needs java 1.7 or newer
SKIP_TOMCAT_8 = confine_8_array.any?
