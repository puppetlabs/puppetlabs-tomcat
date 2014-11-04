require 'spec_helper'

describe 'tomcat::config::server::listener', :type => :define do
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
    'JmxRemoteLifecycleListener'
  end
  context 'Add Listener' do
    let :params do
      {
         :catalina_base         => '/opt/apache-tomcat/test',
         :class_name             => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
         :listener_ensure       => 'present',
         :additional_attributes => {
           'rmiRegistryPortPlatform' => '10001',
           'rmiServerPortPlatform'   => '10002',
         },
         :attributes_to_remove  => [
           'foo',
           'bar',
           'baz',
         ],
      }
    end
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'set Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/class_name org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
        'set Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/rmiRegistryPortPlatform 10001',
        'set Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/rmiServerPortPlatform 10002',
        'rm Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/foo',
        'rm Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/bar',
        'rm Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']/#attribute/baz',
      ]
    )
    }
  end
  context 'Remove Listener' do
    let :params do
      {
        :catalina_base   => '/opt/apache-tomcat/test',
        :class_name       => 'org.apache.catalina.mbeans.JmxRemoteLifecycleListener',
        :listener_ensure => 'absent',
      }
    end 
    it { is_expected.to contain_augeas('server-/opt/apache-tomcat/test-listener-JmxRemoteLifecycleListener').with(
      'lens'    => 'Xml.lns',
      'incl'    => '/opt/apache-tomcat/test/conf/server.xml',
      'changes' => [
        'rm Server/Listener[#attribute/class_name=\'org.apache.catalina.mbeans.JmxRemoteLifecycleListener\']'
      ]
    )
    }
  end
  context 'Failing Tests' do
    context 'Bad listener_ensure' do
      let :params do
        {
          :listener_ensure => 'foo',
        }
      end
      it do
        expect {
          is_expected.to compile
        }. to raise_error(Puppet::Error, /does not match/)
      end
    end
    context 'Bad additional_attributes' do
      let :params do
        {
          :additional_attributes => 'foo',
        }
      end
      it do
        expect {
          is_expected.to compile
        }. to raise_error(Puppet::Error, /is not a Hash/)
      end
    end
    context 'Bad attributes_to_remove' do
      let :params do
        {
          :attributes_to_remove => 'foo',
        }
      end
      it do
        expect {
          is_expected.to compile
        }. to raise_error(Puppet::Error, /is not an Array/)
      end
    end
    context 'No class_name' do
      let :params do
        {
          :catalina_base         => '/opt/apache-tomcat/test',
          :listener_ensure       => 'present',
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /must be specified/)
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
