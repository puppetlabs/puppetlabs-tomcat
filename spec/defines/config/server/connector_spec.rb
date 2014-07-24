require 'spec_helper'

describe 'tomcat::config::server::connector', :type => :define do
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
    'HTTP/1.1'
  end
  context 'set all the things' do
    let :params do
      {
        :port                  => '8180',
        :catalina_base         => '/opt/apache-tomcat/test',
        :protocol              => 'AJP/1.3',
        :parent_service        => 'Catalina2',
        :additional_attributes => {
          'redirectPort'      => '8543',
          'connectionTimeout' => '20000',
        },
        :attributes_to_remove  => [
          'foo',
          'bar',
          'baz'
        ],
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina2-connector-AJP/1.3').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/protocol AJP/1.3',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/port 8180',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/redirectPort 8543',
        'set Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/connectionTimeout 20000',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/foo',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/bar',
        'rm Server/Service[#attribute/name=\'Catalina2\']/Connector[#attribute/protocol=\'AJP/1.3\']/#attribute/baz',
      ],
    )
    }
  end
  context 'remove connector' do
    let :params do
      {
        :catalina_base    => '/opt/apache-tomcat/test',
        :connector_ensure => 'absent',
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-Catalina-connector-HTTP/1.1').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Service[#attribute/name=\'Catalina\']/Connector[#attribute/protocol=\'HTTP/1.1\']',
      ],
    )
    }
  end
  describe 'failing tests' do
    context 'bad connector_ensure' do
      let :params do
        {
          :connector_ensure => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'bad additional_attributes' do
      let :params do
        {
          :additional_attributes => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'no port' do
      let :params do
        {
          :catalina_base => '/opt/apache-tomcat/test',
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /\$port must be specified/)
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
          is_expected.to compile
        }.to raise_error(Puppet::Error, /configurations require Augeas/)
      end
    end
  end
end
