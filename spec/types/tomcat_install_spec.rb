require 'spec_helper'

describe Puppet::Type.type(:tomcat_install) do
  describe 'when validating attributes' do
    %i[catalina_home].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
    %i[user group version].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end
  end
end
