# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat', type: :class do
  context 'not installing from source' do
    let :facts do
      {
        os: {
          family: 'Debian',
        },
      }
    end
    let :params do
      {
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
  end

  context 'not managing user/group' do
    let :facts do
      {
        os: {
          family: 'Debian',
        },
      }
    end
    let :params do
      {
        manage_user: false,
        manage_group: false,
      }
    end

    it { is_expected.not_to contain_user('tomcat') }
    it { is_expected.not_to contain_group('tomcat') }
  end

  context 'with invalid $manage_user' do
    let :facts do
      {
        os: {
          family: 'Debian',
        },
      }
    end
    let :params do
      {
        manage_user: 'foo',
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, %r{Boolean})
    end
  end

  context 'on windows' do
    let :facts do
      {
        os: {
          family: 'windows',
        },
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, %r{Unsupported os family})
    end
  end
  context 'on Solaris' do
    let :facts do
      {
        os: {
          family: 'Solaris',
        },
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, %r{Unsupported os family})
    end
  end
  context 'on OSX' do
    let :facts do
      {
        os: {
          family: 'Darwin',
        },
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, %r{Unsupported os family})
    end
  end
end
