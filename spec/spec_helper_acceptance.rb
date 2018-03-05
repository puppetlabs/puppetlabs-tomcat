require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'rspec/retry'

run_puppet_install_helper
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

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

def latest_daemon_version(tomcat_version)
  require 'net/http'
  build_value = tomcat_version.match(%r{(\d+)\.(\d+)\.(\d+)})
  uri = "http://svn.apache.org/repos/asf/tomcat/tc#{build_value[1]}.#{build_value[2]}.x/tags/TOMCAT_#{build_value[1]}_#{build_value[2]}_#{build_value[3]}/build.properties.default"
  page = Net::HTTP.get(URI(uri))
  latest_version = page.match(%r{(?:commons-daemon.version=)(\d.\d.\d)})[1]
  latest_version
end

latest7 = latest_tomcat_tarball_url('7')
latest8 = latest_tomcat_tarball_url('8')
latest9 = latest_tomcat_tarball_url('9')

TOMCAT7_RECENT_VERSION = ENV['TOMCAT7_RECENT_VERSION'] || latest7
TOMCAT7_RECENT_SOURCE = latest7
puts "TOMCAT7_RECENT_SOURCE is #{TOMCAT7_RECENT_SOURCE.inspect}"
TOMCAT8_RECENT_VERSION = ENV['TOMCAT8_RECENT_VERSION'] || latest8
TOMCAT8_RECENT_SOURCE = latest8
puts "TOMCAT8_RECENT_SOURCE is #{TOMCAT8_RECENT_SOURCE.inspect}"
TOMCAT9_RECENT_VERSION = ENV['TOMCAT9_RECENT_VERSION'] || latest9
TOMCAT9_RECENT_SOURCE = latest9
puts "TOMCAT9_RECENT_SOURCE is #{TOMCAT9_RECENT_SOURCE.inspect}"
TOMCAT_LEGACY_VERSION = ENV['TOMCAT_LEGACY_VERSION'] || '7.0.78'
# Please note that these URLs are http and therefore insecure. To remedy this you can change them to https, although some additional work may be required to match the required protocols of the server.
TOMCAT_LEGACY_SOURCE = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{TOMCAT_LEGACY_VERSION}/bin/apache-tomcat-#{TOMCAT_LEGACY_VERSION}.tar.gz".freeze
SAMPLE_WAR = 'http://tomcat.apache.org/tomcat-9.0-doc/appdev/sample/sample.war'.freeze

LATEST_DAEMON_8 = latest_daemon_version(TOMCAT8_RECENT_VERSION)

UNSUPPORTED_PLATFORMS = %w[windows Solaris Darwin].freeze

# Tomcat 7 needs java 1.6 or newer
SKIP_TOMCAT_7 = false

# Tomcat 8 needs java 1.7 or newer
confine_8_array = [
  (fact('operatingsystem') == 'Ubuntu'  &&  fact('operatingsystemrelease') == '10.04'),
  (fact('osfamily') == 'RedHat'         &&  fact('operatingsystemmajrelease') == '5'),
  (fact('operatingsystem') == 'Debian'  &&  fact('operatingsystemmajrelease') == '6'),
  (fact('osfamily') == 'Suse'           &&  fact('operatingsystemmajrelease') == '11'),
]
# puppetlabs-gcc doesn't work on Suse
confine_gcc_array = [
  (fact('osfamily') == 'Suse'           &&  fact('operatingsystemmajrelease') == '11'),
  (fact('osfamily') == 'Suse'           &&  fact('operatingsystemmajrelease') == '12'),
]
SKIP_TOMCAT_8 = confine_8_array.any?
SKIP_GCC = confine_gcc_array.any?

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.verbose_retry = true
  c.display_try_failure_messages = true

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-java'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-gcc'), acceptable_exit_codes: [0, 1]
      if fact('osfamily') == 'RedHat'
        on host, 'yum install -y nss'
      end
    end
  end
end
