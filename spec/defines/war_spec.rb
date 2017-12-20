require 'spec_helper'

describe 'tomcat::war', type: :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :facts do
    {
      osfamily: 'Debian',
    }
  end
  let :title do
    'sample.war'
  end

  context 'basic deployment' do
    let :params do
      {
        war_source: '/tmp/sample.war',
      }
    end

    it {
      is_expected.to contain_archive('tomcat::war sample.war').with(
        'source' => '/tmp/sample.war',
        'path'   => '/opt/apache-tomcat/webapps/sample.war',
      )
    }
    it {
      is_expected.to contain_file('tomcat::war sample.war').with(
        'ensure' => 'file', 'path' => '/opt/apache-tomcat/webapps/sample.war',
        'owner' => 'tomcat', 'group' => 'tomcat', 'mode' => '0640'
      ).that_subscribes_to('Archive[tomcat::war sample.war]')
    }
  end
  context 'basic undeployment' do
    let :params do
      {
        war_ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_file('/opt/apache-tomcat/webapps/sample.war').with(
        'ensure' => 'absent',
        'force'  => 'false',
      )
    }
    it {
      is_expected.to contain_file('/opt/apache-tomcat/webapps/sample').with(
        'ensure' => 'absent',
        'force'  => 'true',
      )
    }
  end
  context 'set everything' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/test',
        app_base: 'webapps2',
        war_ensure: 'present',
        war_name: 'sample2.war',
        war_source: '/tmp/sample.war',
        allow_insecure: true,
      }
    end

    it {
      is_expected.to contain_archive('tomcat::war sample.war').with(
        'source'         => '/tmp/sample.war',
        'path'           => '/opt/apache-tomcat/test/webapps2/sample2.war',
        'allow_insecure' => true,
      )
    }
    it {
      is_expected.to contain_file('tomcat::war sample.war').with(
        'ensure' => 'file', 'path' => '/opt/apache-tomcat/test/webapps2/sample2.war',
        'owner' => 'tomcat', 'group' => 'tomcat', 'mode' => '0640'
      ).that_subscribes_to('Archive[tomcat::war sample.war]')
    }
  end
  context 'set deployment_path' do
    let :params do
      {
        deployment_path: '/opt/apache-tomcat/webapps3',
        war_source: '/tmp/sample.war',
      }
    end

    it {
      is_expected.to contain_archive('tomcat::war sample.war').with(
        'source' => '/tmp/sample.war',
        'path'   => '/opt/apache-tomcat/webapps3/sample.war',
      )
    }
    it {
      is_expected.to contain_file('tomcat::war sample.war').with(
        'ensure' => 'file', 'path' => '/opt/apache-tomcat/webapps3/sample.war',
        'owner' => 'tomcat', 'group' => 'tomcat', 'mode' => '0640'
      ).that_subscribes_to('Archive[tomcat::war sample.war]')
    }
  end
  context 'war_purge is false' do
    let :params do
      {
        war_ensure: 'absent',
        war_purge: false,
      }
    end

    it {
      is_expected.to contain_file('/opt/apache-tomcat/webapps/sample.war').with(
        'ensure' => 'absent',
        'force'  => 'false',
      )
    }
    it {
      is_expected.not_to contain_file('/opt/apache-tomcat/webapps/sample').with(
        'ensure' => 'absent',
        'force'  => 'true',
      )
    }
  end
  describe 'failing tests' do
    context 'bad war name' do
      let :params do
        {
          war_name: 'foo',
          war_source: '/tmp/sample.war',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{war_name})
      end
    end
    context 'bad ensure' do
      let :params do
        {
          war_ensure: 'foo',
          war_source: '/tmp/sample.war',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{(String|foo)})
      end
    end
    context 'bad purge' do
      let :params do
        {
          war_ensure: 'absent',
          war_purge: 'foo',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{Boolean})
      end
    end
    context 'invalid source' do
      let :params do
        {
          war_source: 'foo',
        }
      end

      it do
        expect {
          catalogue.to_ral
        }.to raise_error(Puppet::Error, %r{invalid source url})
      end
    end
    context 'no source' do
      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{\$war_source must be specified})
      end
    end
    context 'both app_base and deployment_path' do
      let :params do
        {
          war_source: '/tmp/sample.war',
          app_base: 'webapps2',
          deployment_path: '/opt/apache-tomcat/webapps3',
        }
      end

      it do
        expect {
          catalogue
        }.to raise_error(Puppet::Error, %r{Only one of \$app_base and \$deployment_path can be specified})
      end
    end
    context 'set owner/group to war file' do
      let :params do
        {
          catalina_base: '/opt/apache-tomcat',
          app_base: 'webapps2',
          war_ensure: 'present',
          war_name: 'sample2.war',
          war_source: '/tmp/sample.war',
          allow_insecure: true,
          user: 'tomcat2',
          group: 'tomcat2',
        }
      end

      it {
        is_expected.to contain_archive('tomcat::war sample.war').with(
          'source'         => '/tmp/sample.war',
          'path'           => '/opt/apache-tomcat/webapps2/sample2.war',
          'allow_insecure' => true,
        )
      }
      it {
        is_expected.to contain_file('tomcat::war sample.war').with(
          'ensure' => 'file', 'path' => '/opt/apache-tomcat/webapps2/sample2.war',
          'owner' => 'tomcat2', 'group' => 'tomcat2', 'mode' => '0640'
        ).that_subscribes_to('Archive[tomcat::war sample.war]')
      }
    end
  end
end
