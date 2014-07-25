require 'spec_helper'

describe 'tomcat', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end
    it { is_expected.to contain_class("tomcat::params") }
    it { is_expected.to contain_file("/opt/apache-tomcat").with(
      'ensure' => 'directory',
      'owner'  => 'tomcat',
      'group'  => 'tomcat',
      )
    }
    it { is_expected.to contain_user("tomcat").with(
      'ensure' => 'present',
      'gid'    => 'tomcat',
      )
    }
    it { is_expected.to contain_group("tomcat").with(
      'ensure' => 'present'
      )
    }
  end

  context "not managing user/group" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end
    let :params do
      {
        :manage_user  => false,
        :manage_group => false
      }
    end
    it { is_expected.not_to contain_user("tomcat") }
    it { is_expected.not_to contain_group("tomcat") }
  end

  context "with invalid $manage_user" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end
    let :params do
      {
        :manage_user => 'foo'
      }
    end
    it do
      expect {
        is_expected.to compile
      }.to raise_error(Puppet::Error, /is not a boolean/)
    end
  end

  context "on windows" do
    # TestRail test case c9982
    let :facts do
      {
        :osfamily => 'windows'
      }
    end
    it do
      expect {
       is_expected.to compile
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    end
  end
  context "on Solaris" do
    # TestRail test case c9983
    let :facts do
      {
        :osfamily => 'Solaris'
      }
    end
    it do
      expect {
       is_expected.to compile
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    end
  end
  context "on OSX" do
    # TestRail test case c13850
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end
    it do
      expect {
       is_expected.to compile
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    end
  end
end
