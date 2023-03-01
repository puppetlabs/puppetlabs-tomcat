# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::server', type: :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      os: { family: 'Debian' },
      augeas: { version: '1.0.0' },
    }
  end
  let :title do
    'default'
  end

  context 'add everything' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        class_name: 'foo',
        address: 'localhost',
        port: '8005',
        shutdown: 'SHUTDOWN',
      }
    end

    changes = [
      'set Server/#attribute/className foo',
      'set Server/#attribute/address localhost',
      'set Server/#attribute/port 8005',
      'set Server/#attribute/shutdown SHUTDOWN',
    ]
    it {
      is_expected.to contain_augeas('server-/opt/apache-tomcat/test').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
        'changes' => changes,
      )
    }
  end
  context 'custom server_config location' do
    let(:params) do
      {
        catalina_base: '/opt/apache-tomcat/test',
        class_name: 'foo',
        address: 'localhost',
        port: '8005',
        shutdown: 'SHUTDOWN',
        server_config: '/opt/apache-tomcat/server.xml',
      }
    end

    changes = [
      'set Server/#attribute/className foo',
      'set Server/#attribute/address localhost',
      'set Server/#attribute/port 8005',
      'set Server/#attribute/shutdown SHUTDOWN',
    ]
    it {
      is_expected.to contain_augeas('server-/opt/apache-tomcat/test').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/server.xml',
        'changes' => changes,
      )
    }
  end
  context 'remove optional attributes' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        class_name_ensure: 'absent',
        address_ensure: 'absent',
      }
    end

    changes = [
      'rm Server/#attribute/className',
      'rm Server/#attribute/address',
    ]
    it {
      is_expected.to contain_augeas('server-/opt/apache-tomcat/test').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
        'changes' => changes,
      )
    }
  end
  context 'no changes' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
      }
    end

    it { is_expected.not_to contain_augeas('server-/opt/apache-tomcat/test') }
  end
  describe 'failing tests' do
    context 'invalid class_name_ensure' do
      let :params do
        {
          class_name_ensure: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{(String|foo)})
      end
    end
    context 'invalid address_ensure' do
      let :params do
        {
          address_ensure: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{(String|foo)})
      end
    end
    context 'old augeas' do
      let :facts do
        {
          os: { family: 'Debian' },
          augeas: { version: '0.10.0' },
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{configurations require Augeas})
      end
    end
  end
end
