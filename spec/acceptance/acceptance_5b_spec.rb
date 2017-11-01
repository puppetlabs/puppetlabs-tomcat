require 'spec_helper_acceptance'

stop_test = (UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up } || SKIP_TOMCAT_8)

describe 'Test tomcat install custom type', docker: true, unless: stop_test do
  after :all do
    shell('pkill -f tomcat', acceptable_exit_codes: [0, 1])
    shell('rm -rf /opt/tomcat*', acceptable_exit_codes: [0, 1])
    shell('rm -rf /opt/apache-tomcat*', acceptable_exit_codes: [0, 1])
  end

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'java':}
      class { 'tomcat': catalina_home => '/opt/apache-tomcat40', }

      user { 'tomcat':
        ensure => present,
      }

      group { 'tomcat':
        ensure => present,
      }

      tomcat_install { '/opt/apache-tomcat40':
        ensure => present,
        version => '7.0.82',
      }
      EOS
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'Delete and reinstall' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'java':}
      class { 'tomcat': catalina_home => '/opt/apache-tomcat40', }

      user { 'tomcat':
        ensure => present,
      }

      group { 'tomcat':
        ensure => present,
      }

      tomcat_install { '/opt/apache-tomcat40':
        ensure => present,
        version => '7.0.82',
      }
      EOS
      shell('rm -rf /opt/apache-tomcat*', acceptable_exit_codes: [0, 1])
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
  end

  context 'Change to early version' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'java':}
      class { 'tomcat': catalina_home => '/opt/apache-tomcat40', }

      user { 'tomcat':
        ensure => present,
      }

      group { 'tomcat':
        ensure => present,
      }

      tomcat_install { '/opt/apache-tomcat40':
        ensure => present,
        version => '7.0.14',
      }
      EOS
      apply_manifest(pp, catch_failures: true, acceptable_exit_codes: [0, 2])
    end
  end

 context 'No version on install should fail' do
   it 'Should apply the manifest without error' do
     pp = <<-EOS
     tomcat_install { '/opt/apache-tomcat40':
       ensure => present,
     }
     EOS
     apply_manifest(pp, expect_failures: true, acceptable_exit_codes: [0, 2])
   end
 end

  context 'No ensure on install should fail' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat_install { '/opt/apache-tomcat40':
        version => '7.0.82,
      }
      EOS
      apply_manifest(pp, expect_failures: true, acceptable_exit_codes: [0, 2])
    end
  end
end
