require 'spec_helper'

describe 'tomcat::config::context::valve', :type => :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'valve'
  end
  context 'Add Valve Resource' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :resource_type         => 'org.apache.catalina.valves.rewrite.RewriteValve',
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-valve-valve').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/Valve[#attribute/name=\'valve\']/#attribute/name valve',
        'set Context/Valve[#attribute/name=\'valve\']/#attribute/className org.apache.catalina.valves.rewrite.RewriteValve',
        'rm Context/Valve[#attribute/name=\'valve\']/#attribute/foobar',
        ]
      )
    }
  end
  context 'Remove Resource' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :ensure        => 'absent',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-valve-valve').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'rm Context/Valve[#attribute/name=\'valve\']',
        ]
      )
    }
  end
end
