require 'spec_helper'

describe 'tomcat::install', :type => :define do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :default_facts do
    {
      :osfamily => 'Debian',
      :path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'default'
  end
  context 'install from source, allow_insecure' do
    let :facts do default_facts end
    let :params do
      {
        :catalina_home  => '/opt/apache-tomcat/test-tomcat',
        :source_url     => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz',
        :allow_insecure => true,
      }
    end
    it { is_expected.to contain_archive('default-/opt/apache-tomcat/test-tomcat/apache-tomcat-8.0.8.tar.gz').with(
        'extract_path'   => '/opt/apache-tomcat/test-tomcat',
        'user'           => 'tomcat',
        'group'          => 'tomcat',
        'extract_flags'  => '--strip 1 -xf',
        'allow_insecure' => true,
      )
    }
  end
end
