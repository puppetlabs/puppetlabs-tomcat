require 'spec_helper'
describe 'tomcat' do

  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('tomcat') }
  end
end
