# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::context::resources' do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :title do
    'Resources'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      merged_facts = if os =~ %r{debian}
                       os_facts.merge(
                         'augeasversion' => '1.0.0',
                       )
                     else
                       os_facts
                     end
      let(:facts) { merged_facts }

      context 'Add Resources' do
        let :params do
          {
            catalina_base: '/opt/apache-tomcat/test',
            ensure: 'present',
            additional_attributes: {
              'allowLinking' => 'true',
            },
            attributes_to_remove: [
              'foobar',
            ],
          }
        end

        changes = [
          'set Context/Resources[#attribute/puppetName=\'Resources\']/#attribute/puppetName Resources',
          'set Context/Resources[#attribute/puppetName=\'Resources\']/#attribute/allowLinking \'true\'',
          'rm Context/Resources[#attribute/puppetName=\'Resources\']/#attribute/foobar',
        ]
        it {
          is_expected.to contain_augeas('context-/opt/apache-tomcat/test-resources-Resources').with(
            'lens' => 'Xml.lns',
            'incl' => '/opt/apache-tomcat/test/conf/context.xml',
            'changes' => changes,
          )
        }

        it { is_expected.to compile }
      end
    end
  end
end
