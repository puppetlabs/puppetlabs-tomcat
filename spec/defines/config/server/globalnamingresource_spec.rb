# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::server::globalnamingresource', type: :define do
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
    'TestGlobalNamingResource'
  end

  context 'creates or updates resource element' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        resource_name: 'TestGlobalNamingResource',
        additional_attributes: {
          'type' => 'org.apache.catalina.TestGlobalNamingResource',
          'description' => 'Test global naming resource',
        },
      }
    end

    changes = [
      "set Server/GlobalNamingResources/Resource[#attribute/name='TestGlobalNamingResource']/#attribute/type 'org.apache.catalina.TestGlobalNamingResource'",
      "set Server/GlobalNamingResources/Resource[#attribute/name='TestGlobalNamingResource']/#attribute/description 'Test global naming resource'",
    ]

    it {
      expect(subject).to contain_augeas('server-/opt/apache-tomcat/test-globalresource-TestGlobalNamingResource-definition')
    }

    it {
      expect(subject).to contain_augeas('server-/opt/apache-tomcat/test-globalresource-TestGlobalNamingResource').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/server.xml',
        'changes' => changes,
      )
    }
  end

  context 'removes resource element' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        resource_name: 'TestGlobalNamingResource',
        ensure: 'absent',
      }
    end

    changes = [
      "rm Server/GlobalNamingResources/Resource[#attribute/name='TestGlobalNamingResource']",
    ]

    it {
      expect(subject).not_to contain_augeas('server-/opt/apache-tomcat/test-globalresource-TestGlobalNamingResource-definition')
    }

    it {
      expect(subject).to contain_augeas('server-/opt/apache-tomcat/test-globalresource-TestGlobalNamingResource').with(
        'lens' => 'Xml.lns',
        'incl' => '/opt/apache-tomcat/test/conf/server.xml',
        'changes' => changes,
      )
    }
  end
end
