require 'spec_helper'

describe 'tomcat::config::server::tomcat_users', type: :define do
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
    'tomcat-users'
  end

  context 'Add User with manage_file' do
    let :title do
      'user-foo'
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element: 'user',
        element_name: 'foo',
        ensure: 'present',
        manage_file: true,
        password: 'bar',
        roles: %w[
          foo_role
          bar_role
        ],
      }
    end

    changes = [
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/username \'foo\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/password \'bar\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/roles \'foo_role,bar_role\'',
    ]
    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-user-foo-user-foo').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => changes,
      )
    }
    it do
      is_expected.to contain_file('/opt/apache-tomcat/test/conf/tomcat-users.xml').with('ensure' => 'file',
                                                                                        'owner'   => 'tomcat',
                                                                                        'group'   => 'tomcat',
                                                                                        'mode'    => '0640',
                                                                                        'replace' => false).that_comes_before('Augeas[/opt/apache-tomcat/test-tomcat_users-user-foo-user-foo]')
    end
  end
  context 'Add User no element' do
    let :title do
      'user-foo'
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element_name: 'foo',
        password: 'very-secret-password',
        roles: ['foobar'],
      }
    end

    changes = [
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/username \'foo\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/password \'very-secret-password\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/roles \'foobar\'',
    ]
    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-user-foo-user-foo').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => changes,
      )
    }
  end
  context 'Add User to empty file' do
    let :title do
      'user-foo'
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        file: '/opt/apache-tomcat/test/conf/users.xml',
        manage_file: true,
        element_name: 'foo',
        password: 'bar',
        roles: ['role'],
      }
    end

    changes = [
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/username \'foo\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/password \'bar\'',
      'set tomcat-users/user[#attribute/username=\'foo\']/#attribute/roles \'role\'',
    ]
    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-user-foo-user-foo').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/users.xml',
        'changes' => changes,
      )
    }
    it do
      is_expected.to contain_file('/opt/apache-tomcat/test/conf/users.xml').with('ensure' => 'file', 'owner' => 'tomcat', 'group' => 'tomcat',
                                                                                 'mode' => '0640', 'replace' => false,
                                                                                 'content' => '<?xml version=\'1.0\' encoding=\'utf-8\'?><tomcat-users></tomcat-users>').that_comes_before('Augeas[/opt/apache-tomcat/test-tomcat_users-user-foo-user-foo]') # rubocop:disable Metrics/LineLength
    end
  end
  context 'Remove User' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element_name: 'foo',
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-user-foo-tomcat-users').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => ['rm tomcat-users/user[#attribute/username=\'foo\']'],
      )
    }
  end
  context 'Add Role with manage_file false' do
    let :title do
      'role-foobar'
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element: 'role',
        element_name: 'foobar',
        manage_file: false,
        ensure: 'present',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-role-foobar-role-foobar').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => ['set tomcat-users/role[#attribute/rolename=\'foobar\']/#attribute/rolename \'foobar\''],
      )
    }
    it { is_expected.not_to contain_file('/opt/apache-tomcat/test/conf/tomcat-users.xml') }
  end
  context 'Add Role no element_name' do
    let :title do
      'noname'
    end
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element: 'role',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-role-noname-noname').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => ['set tomcat-users/role[#attribute/rolename=\'noname\']/#attribute/rolename \'noname\''],
      )
    }
  end
  context 'Remove Role' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        element: 'role',
        element_name: 'foobar',
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('/opt/apache-tomcat/test-tomcat_users-role-foobar-tomcat-users').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/test/conf/tomcat-users.xml',
        'changes' => ['rm tomcat-users/role[#attribute/rolename=\'foobar\']'],
      )
    }
  end
  context 'Failing Tests' do
    context 'Bad ensure' do
      let :params do
        {
          ensure: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }. to raise_error(Puppet::Error, %r{(String|foo)})
      end
    end
    context 'Bad manage_file' do
      let :params do
        {
          manage_file: 'true',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{Boolean})
      end
    end
    context 'Bad roles' do
      let :params do
        {
          roles: 'foo',
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
