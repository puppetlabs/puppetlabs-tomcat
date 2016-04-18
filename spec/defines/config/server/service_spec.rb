require 'spec_helper'

describe 'tomcat::config::server::service', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'Catalina'
  end
  context 'set classname' do
    let :params do
      {
        :catalina_base     => '/opt/apache-tomcat/test',
        :class_name        => 'foo',
        :class_name_ensure => 'true',
        :server_config     => '/opt/apache-tomcat/server.xml',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Catalina').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/#attribute/name Catalina',
        'set Server/Service[#attribute/name=\'Catalina\']/#attribute/className foo',
      ]
    ) }
  end
  context 'set specific service_name' do
    let :params do
      {
        :service_name      => 'Foobar',
        :catalina_base     => '/opt/apache-tomcat/test',
        :class_name_ensure => 'false',
        :server_config     => '/opt/apache-tomcat/server.xml',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Foobar').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Foobar\']/#attribute/name Foobar',
        'rm Server/Service[#attribute/name=\'Foobar\']/#attribute/className',
      ]
    ) }
  end
  context 'remove classname' do
    let :params do
      {
        :catalina_base     => '/opt/apache-tomcat/test',
        :class_name_ensure => 'false',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Catalina').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/#attribute/name Catalina',
        'rm Server/Service[#attribute/name=\'Catalina\']/#attribute/className',
      ]
    ) }
  end
  context 'remove service' do
    let :params do
      {
        :catalina_base  => '/opt/apache-tomcat/test',
        :service_ensure => 'false',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Catalina').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']',
      ]
    ) }
  end
  context 'remove service with specific service_name' do
    let :params do
      {
        :service_name   => 'Foobar',
        :catalina_base  => '/opt/apache-tomcat/test',
        :service_ensure => 'false',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Foobar').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Foobar\']',
      ]
    ) }
  end
  context 'no changes' do
    let :params do
      {
        :catalina_base  => '/opt/apache-tomcat/test',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-service-Catalina').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina\']/#attribute/name Catalina',
      ]
    ) }
  end
  describe 'failing tests' do
    context 'bad service_ensure' do
      let :params do
        {
          :service_ensure => 'foo'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad class_name_ensure' do
      let :params do
        {
          :class_name_ensure => 'foo'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'old augeas' do
      let :facts do
        {
          :osfamily      => 'Debian',
          :augeasversion => '0.10.0'
        }
      end
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, /configurations require Augeas/)
      end
    end
  end
end
