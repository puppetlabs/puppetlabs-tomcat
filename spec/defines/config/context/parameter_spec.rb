require 'spec_helper'

describe 'tomcat::config::context::parameter', type: :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      osfamily: 'Debian',
      augeasversion: '1.0.0',
    }
  end

  let :title do
    'maxExemptions'
  end

  context 'Add Parameter' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        parameter_name: 'maxExemptions',
        value: '10',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-parameter-maxExemptions').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
        'changes' => [
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/value 10',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/override',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/description',
        ],
      )
    }
  end

  context 'Remove Parameter' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-parameter-maxExemptions').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
        'changes' => [
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']',
        ],
      )
    }
  end

  context 'No parameter_name' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        value: '10',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-parameter-maxExemptions').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
        'changes' => [
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/value 10',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/override',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/description',
        ],
      )
    }
  end

  context 'Set override' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        value: '10',
        override: true,
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-parameter-maxExemptions').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
        'changes' => [
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/value 10',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/override true',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/description',
        ],
      )
    }
  end

  context 'Set description' do
    let :params do
      {
        catalina_base: '/opt/apache-tomcat/foo',
        value: '10',
        description: 'foo bar',
      }
    end

    it {
      is_expected.to contain_augeas('context-/opt/apache-tomcat/foo-parameter-maxExemptions').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/opt/apache-tomcat/foo/conf/context.xml',
        'changes' => [
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/name maxExemptions',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/value 10',
          'rm Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/override',
          'set Context/Parameter[#attribute/name=\'maxExemptions\']/#attribute/description \'foo bar\'',
        ],
      )
    }
  end
end
