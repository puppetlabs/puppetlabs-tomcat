# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::context::manager', type: :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      os: { family: 'Debian' },
      augeas: { version: '1.0.0' },
    }
  end
  let :title do
    'memcached'
  end

  context 'Add Manager' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        manager_classname: 'memcached',
        additional_attributes: {
          'barfoo'  => 'foofoo',
          'fizz'    => 'buzz',
        },
        attributes_to_remove: [
          'foobar',
        ],
      }
    end

    changes = [
      'set Context/Manager[#attribute/className=\'memcached\']/#attribute/className \'memcached\'',
      'set Context/Manager[#attribute/className=\'memcached\']/#attribute/barfoo \'foofoo\'',
      'set Context/Manager[#attribute/className=\'memcached\']/#attribute/fizz \'buzz\'',
      'rm Context/Manager[#attribute/className=\'memcached\']/#attribute/foobar',
    ]
    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/test-manager-memcached').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/context.xml',
        'changes' => changes,
      )
    }
  end
  context 'Remove Manager' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/test-manager-memcached').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/context.xml',
        'changes' => ['rm Context/Manager[#attribute/className=\'memcached\']'],
      )
    }
  end
end
