# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::instance', type: :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :default_facts do
    {
      os: { family: 'Debian' },
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'default'
  end

  context 'default install from source' do
    let :facts do
      default_facts
    end
    let :params do
      {
        source_url: 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end

    it {
      is_expected.to contain_user('tomcat').with(
        'ensure' => 'present',
        'gid'    => 'tomcat',
      )
    }
    it {
      is_expected.to contain_group('tomcat').with(
        'ensure' => 'present',
      )
    }
    it {
      is_expected.to contain_file('/opt/apache-tomcat').with(
        'ensure' => 'directory',
        'owner'  => 'tomcat',
        'group'  => 'tomcat',
      )
    }
    it {
      is_expected.to contain_archive('default-/opt/apache-tomcat/apache-tomcat-8.0.8.tar.gz').with(
        'extract_path' => '/opt/apache-tomcat', 'user' => 'tomcat',
        'group' => 'tomcat', 'extract_flags' => '--strip 1 -xf'
      )
    }
  end
  context 'install from source, different catalina_base' do
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test-tomcat',
        source_url: 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
      }
    end

    it {
      is_expected.to contain_archive('default-/opt/apache-tomcat/test-tomcat/apache-tomcat-8.0.8.tar.gz').with(
        'extract_path' => '/opt/apache-tomcat/test-tomcat', 'user' => 'tomcat',
        'group' => 'tomcat', 'extract_flags' => '--strip 1 -xf'
      )
    }
    it {
      is_expected.to contain_file('/opt/apache-tomcat/test-tomcat').with(
        'ensure' => 'directory',
        'owner'  => 'tomcat',
        'group'  => 'tomcat',
      )
    }
  end
  context 'install from package' do
    let :facts do
      default_facts
    end
    let :params do
      {
        install_from_source: false,
        package_name: 'tomcat',
      }
    end

    it { is_expected.to contain_package('tomcat') }
    context 'with additional package_options set' do
      let :params do
        {
          install_from_source: false,
          package_name: 'tomcat',
          package_options: ['/S'],
        }
      end

      it {
        is_expected.to contain_package('tomcat').with(
          'install_options' => ['/S'],
        )
      }
    end
  end
  context 'install from package, set $catalina_base' do
    let :facts do
      default_facts
    end
    let :params do
      {
        install_from_source: false,
        package_name: 'tomcat',
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
      }
    end

    # This is supposed to generate a warning, but checking for that isn't
    # currently supported in puppet-rspec, so just make sure it compiles
    it { is_expected.to compile }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context 'install from source, unmanaged home' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        manage_home   => false,
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
  end
  context 'install from source, unmanaged base' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context 'install from source, unmanaged home and base' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        manage_home   => false,
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context 'install from source, unmanaged catalina.properties' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_properties: false,
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/catalina.properties') }
  end
  context 'legacy install from source, unmanaged home/base' do
    let :pre_condition do
      'class { "tomcat": }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        manage_base: false,
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo') }
  end
  context 'install from source, no copy_from_home' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_copy_from_home: false,
      }
    end

    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/catalina.policy') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/context.xml') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/logging.properties') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/server.xml') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/web.xml') }
  end
  context 'install from source, different copy_from_home_mode' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        copy_from_home_mode: '0664',
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/catalina.policy').with_mode('0664') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/context.xml').with_mode('0664') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/logging.properties').with_mode('0664') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/server.xml').with_mode('0664') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/web.xml').with_mode('0664') }
  end
  context 'install from source, different copy_from_home_list' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        copy_from_home_list: '/opt/apache-tomcat/foo/conf/catalina.policy',
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf/catalina.policy') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/context.xml') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/logging.properties') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/server.xml') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf/web.xml') }
  end

  context 'install from source, managed dirs (default)' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/bin') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/lib') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/temp') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/webapps') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/work') }
  end
  context 'install from source, unmanaged dirs' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        manage_dirs: false,
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/bin') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/lib') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/logs') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/temp') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/webapps') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/work') }
  end
  context 'install from source, custom managed dir list' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        dir_list: ['config', 'webappstest'],
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/config') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/webappstest') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/bin') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/lib') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/logs') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/temp') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/webapps') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/work') }
  end
  context 'install from source, dir mode' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        dir_mode: '0775',
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/bin').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/conf').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/lib').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/logs').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/temp').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/webapps').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/work').with_mode('0775') }
  end
  context 'install from source, dir mode with custom dir list' do
    let :pre_condition do
      'tomcat::install { "tomcat6":
        catalina_home => "/opt/apache-tomcat",
        source_url    => "http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz",
      }'
    end
    let :facts do
      default_facts
    end
    let :params do
      {
        catalina_home: '/opt/apache-tomcat',
        catalina_base: '/opt/apache-tomcat/foo',
        dir_list: ['config', 'webappstest'],
        dir_mode: '0775',
      }
    end

    it { is_expected.to contain_file('/opt/apache-tomcat') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/config').with_mode('0775') }
    it { is_expected.to contain_file('/opt/apache-tomcat/foo/webappstest').with_mode('0775') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/bin') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/conf') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/lib') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/logs') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/temp') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/webapps') }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/foo/work') }
  end
  context 'manage service init with service_name' do
    let :facts do
      default_facts
    end
    let :params do
      {
        source_url: 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
        manage_service: true,
        use_jsvc: false,
        use_init: true,
        service_name: 'tomcat-default',
      }
    end

    it { is_expected.to contain_service('tomcat-default') }
  end
end
