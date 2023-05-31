# frozen_string_literal: true

require 'spec_helper'

describe 'tomcat::change' do
  it { is_expected.to run.with_params(nil).and_return(nil) }
  it { is_expected.to run.with_params(2).and_return(2) }
  it { is_expected.to run.with_params('').and_return('') }
  it { is_expected.to run.with_params('string').and_return('string') }
  it { is_expected.to run.with_params(['abc', 2]).and_return(['abc', 2]) }
end
