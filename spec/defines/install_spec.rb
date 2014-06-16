require 'spec_helper'

describe 'tomcat::install', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :default_facts do
    {
      :osfamily => 'Debian'
    }
  end
  let :title do
    'default'
  end
  context 'default install from source' do
    let :facts do default_facts end
    let :params do
      {
        :source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end
    it { should contain_staging__file('apache-tomcat-8.0.8.tar.gz') }
    it { should contain_staging__extract('apache-tomcat-8.0.8.tar.gz').with(
      'target' => '/opt/apache-tomcat',
      'user'   => 'tomcat',
      'group'  => 'tomcat',
      'strip'  => 1,
    )
    }
  end
  context 'default install from source, Solaris' do
    let :facts do
      {
        :osfamily => 'Solaris'
      }
    end
    let :params do
      {
        :source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end
    it { should contain_staging__file('apache-tomcat-8.0.8.tar.gz') }
    it { should contain_staging__extract('apache-tomcat-8.0.8.tar.gz').with(
      'target' => '/opt/apache-tomcat',
      'user'   => 'tomcat',
      'group'  => 'tomcat',
    )
    }
  end
  context 'install from source, different catalina_base' do
    let :facts do default_facts end
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test-tomcat',
        :source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end
    it { should contain_staging__file('apache-tomcat-8.0.8.tar.gz') }
    it { should contain_staging__extract('apache-tomcat-8.0.8.tar.gz').with(
      'target' => '/opt/apache-tomcat/test-tomcat',
      'user'   => 'tomcat',
      'group'  => 'tomcat',
      'strip'  => 1,
    )
    }
    it { should contain_file('/opt/apache-tomcat/test-tomcat').with(
      'ensure' => 'directory',
      'owner'  => 'tomcat',
      'group'  => 'tomcat',
    )
    }
  end
  context "install from package" do
    let :facts do default_facts end
    let :params do
      {
        :install_from_source => false,
        :package_name        => 'tomcat',
      }
    end
    it { should contain_package('tomcat').with(
      'ensure' => 'installed',
    )
    }
  end
  describe "test install failures" do
    let :facts do default_facts end
    context "no source specified" do
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /\$source_url must be specified/)
      end
    end
    context "no package specified" do
      let :params do
        {
          :install_from_source => false
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /\$package_name must be specified/)
      end
    end
    context "bad install_from_source" do
      let :params do
        {
          :install_from_source => 'foo'
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end
    context "bad source_strip_first_dir" do
      let :params do
        {
          :source_strip_first_dir => 'foo'
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end
  end
end
