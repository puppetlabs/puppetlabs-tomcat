# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::context::valve', type: :define do
  let :pre_condition do
    'class {"tomcat": }'
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
        'defnode valve Context/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\'] \'\'',
        'set $valve/#attribute/className \'org.apache.catalina.valves.AccessLogValve\'',
      ]
      it {
        expect(subject).to contain_augeas('context-/opt/apache-tomcat-valve-org.apache.catalina.valves.AccessLogValve').with(
          'lens' => 'Xml.lns',
          'incl' => '/opt/apache-tomcat/conf/context.xml',
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
          additional_attributes: {
            'prefix' => 'localhost_access_log',
            'suffix' => '.txt',
            'pattern' => 'common',
          },
          uniqueness_attributes: [
            'prefix',
            'suffix',
          ],
          attributes_to_remove: [
            'foobar',
          ],
        }
      end

      changes = [
        'defnode valve Context/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\'][#attribute/prefix=\'localhost_access_log\'][#attribute/suffix=\'.txt\'] \'\'',
        'set $valve/#attribute/className \'org.apache.catalina.valves.AccessLogValve\'',
        'set $valve/#attribute/prefix \'localhost_access_log\'',
        'set $valve/#attribute/suffix \'.txt\'',
        'set $valve/#attribute/pattern \'common\'',
        'rm $valve/#attribute/foobar',
      ]
      it {
        expect(subject).to contain_augeas('context-/opt/apache-tomcat/test-valve-valve').with(
          'lens' => 'Xml.lns',
          'incl' => '/opt/apache-tomcat/test/conf/context.xml',
          'changes' => changes,
        )
      }
    end

    context 'with legacy params' do
      let :title do
        'valve'
      end
      let :params do
        {
          resource_type: 'org.apache.catalina.valves.AccessLogValve',
          additional_attributes: {
            'prefix' => 'localhost_access_log',
            'suffix' => '.txt',
            'pattern' => 'common',
          },
        }
      end

      changes = [
        'defnode valve Context/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\'][#attribute/name=\'valve\'] \'\'',
        'set $valve/#attribute/className \'org.apache.catalina.valves.AccessLogValve\'',
        'set $valve/#attribute/name \'valve\'',
        'set $valve/#attribute/prefix \'localhost_access_log\'',
        'set $valve/#attribute/suffix \'.txt\'',
        'set $valve/#attribute/pattern \'common\'',
      ]
      it {
        expect(subject).to contain_augeas('context-/opt/apache-tomcat-valve-valve').with(
          'lens' => 'Xml.lns',
          'incl' => '/opt/apache-tomcat/conf/context.xml',
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
        ensure: 'absent',
      }
    end

    it {
      expect(subject).to contain_augeas('context-/opt/apache-tomcat-valve-org.apache.catalina.valves.AccessLogValve').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/conf/context.xml',
        'changes' => ['rm Context/Valve[#attribute/className=\'org.apache.catalina.valves.AccessLogValve\']'],
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
