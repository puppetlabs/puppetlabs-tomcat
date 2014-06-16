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
    it { is_expected.to contain_service('tomcat-default').with(
      'hasstatus'  => false,
      'hasrestart' => false,
      'ensure'     => 'running',
    )
    }
  end
  context 'using init' do
    let :params do
      {
        :use_jsvc       => false,
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
    context "neither jsvc or init" do
      let :params do
        {
          :use_jsvc => false,
          :use_init => false,
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /One of \$use_init and \$use_jsvc must/)
      end
    end
    context "init without servicename" do
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
  end
end
