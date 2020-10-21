# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::config::server::executor' do
  let :pre_condition do
    'class { "tomcat": }'
  end
  let :title do
    'tomcatThreadPool'
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

      context 'Add Executor' do
        let :params do
          {
            catalina_base: '/opt/apache-tomcat/test',
            ensure: 'present',
            additional_attributes: {
              'namePrefix'      => 'catalina-exec-',
              'maxThreads'      => '100',
              'minSpareThreads' => '4',
            },
            attributes_to_remove: [
              'foobar',
            ],
          }
        end

        changes = [
          'set Server/Service[#attribute/name=\'Catalina\']/Executor[#attribute/name=\'tomcatThreadPool\']/#attribute/name tomcatThreadPool',
          'set Server/Service[#attribute/name=\'Catalina\']/Executor[#attribute/name=\'tomcatThreadPool\']/#attribute/namePrefix \'catalina-exec-\'',
          'set Server/Service[#attribute/name=\'Catalina\']/Executor[#attribute/name=\'tomcatThreadPool\']/#attribute/maxThreads \'100\'',
          'set Server/Service[#attribute/name=\'Catalina\']/Executor[#attribute/name=\'tomcatThreadPool\']/#attribute/minSpareThreads \'4\'',
          'rm Server/Service[#attribute/name=\'Catalina\']/Executor[#attribute/name=\'tomcatThreadPool\']/#attribute/foobar',
        ]
        it {
          is_expected.to contain_augeas('server-/opt/apache-tomcat/test-executor-tomcatThreadPool').with(
            'lens' => 'Xml.lns',
            'incl' => '/opt/apache-tomcat/test/conf/server.xml',
            'changes' => changes,
          )
        }

        it { is_expected.to compile }
      end
    end
  end
end
