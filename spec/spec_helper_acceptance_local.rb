require 'rspec/retry'

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.verbose_retry = true
  c.display_try_failure_messages = true

  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    run_shell('puppet module install puppetlabs-gcc')
    run_shell('puppet module install puppetlabs-java')
    if os[:family] == 'redhat' && os[:release].to_i != 8
      run_shell('puppet module install stahnma/epel')
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
      apply_manifest(pp)

      run_shell('yum update -y')
      run_shell('yum install -y crontabs tar wget openssl iproute which initscripts nss')
    elsif os[:family] == 'ubuntu'
      run_shell('rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl', expect_failures: true)
      run_shell('apt-get update && apt-get install -y net-tools wget && locale-gen en_US.UTF-8', expect_failures: true)
    elsif os[:family] == 'debian'
      run_shell('apt-get update && apt-get install -y net-tools wget locales strace lsof && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen', expect_failures: true)
    end
  end
end

def latest_tomcat_tarball_url(version)
  require 'net/http'
  page = Net::HTTP.get(URI("http://tomcat.apache.org/download-#{version}0.cgi"))

  url = ((match = page.match(%r{https?://.*?apache-tomcat-(.{4,9}).tar.gz})) && match[0])
  return url if url

  mirror_url = ((match = page.match(%r{<strong>(https?://.*?)/</strong>})) && match[1])
  page = Net::HTTP.get(URI("#{mirror_url}/tomcat/tomcat-#{version}/"))
  latest_version = ((match = page.match(%r{href="v(.{4,9})/"})) && match[1])

  "#{mirror_url}/tomcat/tomcat-#{version}/v#{latest_version}/bin/apache-tomcat-#{latest_version}.tar.gz"
end

latest7 = latest_tomcat_tarball_url('7')
# TODO: Using 8.5.39 until 8.5.45 is replaced
# latest8 = latest_tomcat_tarball_url('8')
latest9 = latest_tomcat_tarball_url('9')

TOMCAT7_RECENT_VERSION = ENV['TOMCAT7_RECENT_VERSION'] || latest7
TOMCAT7_RECENT_SOURCE = latest7
puts "TOMCAT7_RECENT_SOURCE is #{TOMCAT7_RECENT_SOURCE.inspect}"

# TODO: Using 8.5.39 until 8.5.45 is replaced
TOMCAT8_RECENT_VERSION = ENV['TOMCAT8_RECENT_VERSION'] || '8.5.39'
# TOMCAT8_RECENT_SOURCE = latest8
TOMCAT8_RECENT_SOURCE = 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.39/bin/apache-tomcat-8.5.39.tar.gz'.freeze
puts "TOMCAT8_RECENT_SOURCE is #{TOMCAT8_RECENT_SOURCE.inspect}"

TOMCAT9_RECENT_VERSION = ENV['TOMCAT9_RECENT_VERSION'] || latest9
TOMCAT9_RECENT_SOURCE = latest9
puts "TOMCAT9_RECENT_SOURCE is #{TOMCAT9_RECENT_SOURCE.inspect}"

TOMCAT_LEGACY_VERSION = ENV['TOMCAT_LEGACY_VERSION'] || '7.0.85'
# Please note that these URLs are http and therefore insecure. To remedy this you can change them to https, although some additional work may be required to match the required protocols of the server.
TOMCAT_LEGACY_SOURCE = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{TOMCAT_LEGACY_VERSION}/bin/apache-tomcat-#{TOMCAT_LEGACY_VERSION}.tar.gz".freeze
SAMPLE_WAR = 'http://tomcat.apache.org/tomcat-9.0-doc/appdev/sample/sample.war'.freeze

UNSUPPORTED_PLATFORMS = ['windows', 'solaris', 'darwin'].freeze

# Tomcat 7 needs java 1.6 or newer
SKIP_TOMCAT_7 = false

confine_8_array = [
  (os[:family] =~ %r{redhat}            &&  os[:release] =~ %r{5}),
  (os[:family] =~ %r{suse}              &&  os[:release] =~ %r{11}),
]

# Tomcat 8 needs java 1.7 or newer
SKIP_TOMCAT_8 = confine_8_array.any?

# puppetlabs-gcc doesn't work on Suse
SKIP_GCC = (os[:family] == 'suse')
