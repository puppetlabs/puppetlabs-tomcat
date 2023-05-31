# frozen_string_literal: true

# This function exists for usage of a returning the input params that is a deferred function
# Will be used for deferring the values at agent level
Puppet::Functions.create_function(:'tomcat::change') do
  dispatch :change do
    param 'Any', :arg
    return_type 'Any'
  end

  def change(arg)
    arg
  end
end
