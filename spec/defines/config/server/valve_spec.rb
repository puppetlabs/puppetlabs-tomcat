# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::server::valve', type: :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      os: { family: 'Debian' },
      augeas: { version: '1.0.0' },
    }
  end

  context 'Add Valve Resource' do
    context 'with defaults' do
      let :title do
        'org.apache.catalina.valves.AccessLogValve'
      end

      changes = [
        'defnode valve Server/Service[#attribute/name=\'Catalina\']/Engine/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\'] \'\'',
        'set $valve/#attribute/className \'org.apache.catalina.valves.AccessLogValve\'',
      ]
      it {
        is_expected.to contain_augeas('/opt/apache-tomcat-Catalina--valve-org.apache.catalina.valves.AccessLogValve').with(
          'lens' => 'Xml.lns',
          'incl' => '/opt/apache-tomcat/conf/server.xml',
          'changes' => changes,
        )
      }
    end

    context 'with all params' do
      let :title do
        'valve'
      end
      let :params do
        {
          catalina_base: '/opt/apache-tomcat/test',
          class_name: 'org.apache.catalina.valves.AccessLogValve',
          parent_host: 'localhost',
          parent_service: 'Catalina2',
          parent_context: '/var/www/foo',
          server_config: '/opt/apache-tomcat/server.xml',
          additional_attributes: {
            'prefix' => 'localhost_access_log',
            'suffix' => '.txt',
            'pattern' => 'common',
          },
          uniqueness_attributes: [
            'prefix',
            'suffix',
          ],
          attributes_to_remove: ['foo', 'bar'],
        }
      end

      # rubocop:disable Layout/LineLength
      changes = [
        'defnode valve Server/Service[#attribute/name=\'Catalina2\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'/var/www/foo\']/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\'][#attribute/prefix=\'localhost_access_log\'][#attribute/suffix=\'.txt\'] \'\'',
        'set $valve/#attribute/className \'org.apache.catalina.valves.AccessLogValve\'',
        'set $valve/#attribute/prefix \'localhost_access_log\'',
        'set $valve/#attribute/suffix \'.txt\'',
        'set $valve/#attribute/pattern \'common\'',
        'rm $valve/#attribute/foo',
        'rm $valve/#attribute/bar',
      ]
      # rubocop:enable Layout/LineLength
      it {
        is_expected.to contain_augeas('/opt/apache-tomcat/test-Catalina2-localhost-valve-valve').with(
          'lens' => 'Xml.lns',
          'incl' => '/opt/apache-tomcat/server.xml',
          'changes' => changes,
        )
      }
    end
  end

  context 'Remove Resource' do
    let :title do
      'org.apache.catalina.valves.AccessLogValve'
    end
    let :params do
      {
        valve_ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat-Catalina--valve-org.apache.catalina.valves.AccessLogValve').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/conf/server.xml',
        'changes' => 'rm Server/Service[#attribute/name=\'Catalina\']/Engine/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\']',
      )
    }
  end

  describe 'Failing tests' do
    let :title do
      'org.apache.catalina.valves.AccessLogValve'
    end

    context 'bad additional_attributes' do
      let :params do
        {
          additional_attributes: {
            'className' => 'org.apache.catalina.valves.AccessLogValve',
          },
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{Please use parameter})
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
