Puppet::Type.newtype(:tomcat_install) do
  desc "Installs the software into the given directory."

  ensurable

  autorequire(:user) do
    self[:user]
  end

  autorequire(:group) do
    self[:group]
  end

  newparam(:catalina_home, namevar: true) do
    desc "The directory of the Tomcat installation."

    validate do |value|
      raise ArgumentError, "Catalina home is required." if value.nil?
    end
  end

  newparam(:version) do
    desc "Specifies the owner of the source installation directory."

    validate do |value|
      raise ArgumentError, "Tomcat version is required." if value.nil? || value !~ /\d{1,2}\.\d{1,2}\.\d{1,2}/
    end
  end

  newparam(:user) do
    desc "Specifies the owner of the source installation directory."

    defaultto 'tomcat'
  end

  newparam(:group) do
    desc "Specifies the group of the source installation directory."

    defaultto 'tomcat'
  end
end
