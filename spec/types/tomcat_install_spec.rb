require 'spec_helper'

describe Puppet::Type.type(:tomcat_install) do
  describe 'when validating attributes' do
    [:catalina_home, :user, :group, :version].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
    [].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end
  end
end
