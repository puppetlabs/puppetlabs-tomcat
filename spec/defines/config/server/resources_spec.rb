# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::server::resources', type: :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      osfamily: 'Debian',
      augeasversion: '1.0.0',
    }
  end
  let :title do
    'exampleapp.war'
  end

  context 'Add Resources' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'present',
        parent_service: 'Catalina',
        parent_engine: 'Catalina',
        parent_host: 'localhost',
        parent_context: 'parent',
        server_config: '/opt/apache-tomcat/server.xml',
        additional_attributes: {
          'allowLinking' => 'true',
        },
        attributes_to_remove: [
          'foobar',
        ],
      }
    end

    changes = [
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'parent\'] \'\'',
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'parent\']/Resources #empty',
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'parent\']/Resources/#attribute/allowLinking \'true\'', # rubocop:disable Layout/LineLength
      'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'parent\']/Resources/#attribute/foobar',
    ]
    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-parent-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/server.xml',
        'changes' => changes,
      )
    }
  end
  context 'No parent_context' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'present',
        parent_service: 'Catalina',
        parent_engine: 'Catalina',
        parent_host: 'localhost',
        additional_attributes: {
          'foo' => 'bar',
        },
        attributes_to_remove: [
          'foobar',
        ],
      }
    end

    changes = [
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\'] \'\'', # rubocop:disable Layout/LineLength
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/Resources #empty', # rubocop:disable Layout/LineLength
      'set Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/Resources/#attribute/foo \'bar\'', # rubocop:disable Layout/LineLength
      'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/Resources/#attribute/foobar', # rubocop:disable Layout/LineLength
    ]
    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-exampleapp.war-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
        'changes' => changes,
      )
    }
  end
  context 'context with $parent_service' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'present',
        parent_service: 'test',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-test---context-exampleapp.war-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
        'changes' => [
          'set Server/Service[#attribute/name=\'test\']/Engine/Host/Context[#attribute/docBase=\'exampleapp.war\'] \'\'',
          'set Server/Service[#attribute/name=\'test\']/Engine/Host/Context[#attribute/docBase=\'exampleapp.war\']/Resources #empty',
        ],
      )
    }
  end
  context 'context with $parent_host' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'present',
        parent_host: 'localhost',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina--localhost-context-exampleapp.war-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
        'changes' => [
          'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\'] \'\'',
          'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/Resources #empty',
        ],
      )
    }
  end
  context '$parent_engine, no $parent_host' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'present',
        parent_engine: 'Catalina',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina---context-exampleapp.war-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
        'changes' => [
          'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host/Context[#attribute/docBase=\'exampleapp.war\'] \'\'',
          'set Server/Service[#attribute/name=\'Catalina\']/Engine/Host/Context[#attribute/docBase=\'exampleapp.war\']/Resources #empty',
        ],
      )
    }
  end
  context 'Remove Resources' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/exampleapp',
        resources_ensure: 'absent',
        parent_service: 'Catalina',
        parent_engine: 'Catalina',
        parent_host: 'localhost',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/exampleapp-Catalina-Catalina-localhost-context-exampleapp.war-resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/exampleapp/conf/server.xml',
        'changes' => [
          'rm Server/Service[#attribute/name=\'Catalina\']/Engine[#attribute/name=\'Catalina\']/Host[#attribute/name=\'localhost\']/Context[#attribute/docBase=\'exampleapp.war\']/Resources',
        ],
      )
    }
  end
  describe 'Failing Tests' do
    context 'bad resources_ensure' do
      let :params do
        {
          resources_ensure: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{(String|foo)})
      end
    end
    context 'Bad additional_attributes' do
      let :params do
        {
          additional_attributes: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, %r{Hash})
      end
    end
    context 'Bad attributes_to_remove' do
      let :params do
        {
          attributes_to_remove: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, %r{Array})
      end
    end
    context 'old augeas' do
      let :facts do
        {
          osfamily: 'Debian',
          augeasversion: '0.10.0',
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
