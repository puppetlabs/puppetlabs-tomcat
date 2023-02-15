# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::context::resources', type: :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      os: {
        family: 'Debian',
      },
      augeas: {
        version: '1.0.0',
      },
    }
  end
  let :title do
    'attributes'
  end

  context 'Add Resources' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        additional_attributes: {
          'cachingAllowed'  => 'true',
          'cacheMaxSize'    => '100000',
        },
        attributes_to_remove: [
          'foobar',
        ],
      }
    end

    changes = [
      'set Context/Resources[#attribute]/#attribute/cachingAllowed \'true\'',
      'set Context/Resources[#attribute]/#attribute/cacheMaxSize \'100000\'',
      'rm Context/Resources[#attribute]/#attribute/foobar',
    ]
    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resources-attributes').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/context.xml',
        'changes' => changes,
      )
    }
  end

  context 'Remove Resources' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resources-attributes').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/context.xml',
        'changes' => ['rm Context/Resources[#attribute]'],
      )
    }
  end
end
