require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'


unless ENV['RS_PROVISION'] == 'no'
  if default.is_pe?
    install_pe
  else
    install_puppet
  end

  hosts.each do |host|
      on host, "mkdir -p #{host['distmoduledir']}"
  end
end

UNSUPPORTED_PLATFORMS = ['windows','Solaris','Darwin']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'tomcat')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib','--force','--version','4.3.2'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat','--version','1.0.4'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-java'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-gcc'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','nanliu-staging'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
