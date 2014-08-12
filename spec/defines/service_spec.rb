require 'spec_helper'

describe 'tomcat::service', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian'
    }
  end
  let :title do
    'default'
  end
  context 'using jsvc' do
    # TestRail test case c10000
    let :params do
      {
        :use_jsvc => true
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
    )
    }
  end
  context 'set start/stop with jsvc' do
    let :params do
      {
        :use_jsvc      => true,
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'      => '/bin/true',
    )
    }
  end
  context 'using init' do
    # TestRail test case c9999, c10002
    let :params do
      {
        :use_init       => true,
        :service_name   => 'tomcat',
        :service_ensure => 'stopped',
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'stopped'
    )
    }
  end
  context 'set start/stop with init' do
    let :params do
      {
        :use_init      => true,
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
        :service_name  => 'tomcat',
      }
    end
    it { is_expected.to contain_service('tomcat').with(
      'hasstatus'  => true,
      'hasrestart' => true,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'      => '/bin/true',
    )
    }
  end
  # TestRail test cases C9996/9998/10001/10007
  context "neither jsvc or init" do
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => "su -s /bin/bash -c '/opt/apache-tomcat/bin/catalina.sh start' tomcat",
      'stop'       => "su -s /bin/bash -c '/opt/apache-tomcat/bin/catalina.sh stop' tomcat",
    )
    }
  end
  context "default, set start/stop" do
    let :params do
      {
        :start_command => '/bin/true',
        :stop_command  => '/bin/true',
      }
    end
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
      'start'      => '/bin/true',
      'stop'       => '/bin/true',
    )
    }
  end
  describe 'failing tests' do
    context "bad use_jsvc" do
      let :params do
        {
          :use_jsvc => 'foo',
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end
    context "bad use_init" do
      let :params do
        {
          :use_init => 'foo',
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end
    context "both jsvc and init" do
      # TestRail test case c9995
      let :params do
        {
          :use_jsvc => true,
          :use_init => true,
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /Only one of \$use_jsvc and \$use_init/)
      end
    end
    context "init without servicename" do
      # TestRail test case c10005
      let :params do
        {
          :use_jsvc     => false,
          :use_init     => true,
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /\$service_name must be specified/)
      end
    end
    context "java_home without use_jsvc warning" do
      let :params do
        {
          :java_home => 'foo',
        }
      end

      it { is_expected.to compile }
    end
    context "java_home with start_command" do
      let :params do
        {
          :java_home => 'foo',
          :start_command => '/bin/true'
        }
      end

      it { is_expected.to compile }
    end
  end
end
