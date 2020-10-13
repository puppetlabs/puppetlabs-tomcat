# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::context::transaction' do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :title do
    'UserTransaction'
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

      context 'Add Transaction' do
        let :params do
          {
            catalina_base: '/opt/apache-tomcat/test',
            ensure: 'present',
            factory: 'org.objectweb.jotm.UserTransactionFactory',
            additional_attributes: {
              'jotm.timeout' => '60',
            },
            attributes_to_remove: [
              'foobar',
            ],
          }
        end

        changes = [
          'set Context/Transaction[#attribute/puppetName=\'UserTransaction\']/#attribute/puppetName UserTransaction',
          'set Context/Transaction[#attribute/puppetName=\'UserTransaction\']/#attribute/factory org.objectweb.jotm.UserTransactionFactory',
          'set Context/Transaction[#attribute/puppetName=\'UserTransaction\']/#attribute/jotm.timeout \'60\'',
          'rm Context/Transaction[#attribute/puppetName=\'UserTransaction\']/#attribute/foobar',
        ]
        it {
          is_expected.to contain_augeas('context-/opt/apache-tomcat/test-transaction-UserTransaction').with(
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
