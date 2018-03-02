Puppet::Type.newtype(:tomcat_install) do
  desc 'Installs the software into the given directory.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  autorequire(:user) do
    self[:user]
  end

  autorequire(:group) do
    self[:group]
  end

  newparam(:catalina_home, namevar: true) do
    desc 'The directory of the Tomcat installation.'

    validate do |value|
      raise ArgumentError, 'Catalina home is required.' if value.nil?
    end
  end

  newparam(:version) do
    desc 'Specifies the owner of the source installation directory.'

    validate do |value|
      raise ArgumentError, "Tomcat version must be in the form x.y.z, got #{value}" if value !~ %r{\d{1,2}\.\d{1,2}\.\d{1,2}}
    end
  end

  newparam(:source_url) do
    desc 'Specifies the location of the tomcat install file.'

    validate do |value|
      raise ArgumentError, 'Source must be a valid URL.' if value !~ %r{https?:\/\/[\S]+}
    end
  end

  newparam(:user) do
    desc 'Specifies the owner of the source installation directory.'

    defaultto 'tomcat'
  end

  newparam(:group) do
    desc 'Specifies the group of the source installation directory.'

    defaultto 'tomcat'
  end

  validate do
    unless self[:version] || self[:source_url]
      raise(Puppet::Error, 'Version or source url must be included.')
    end

    if self[:version] && self[:source_url]
      raise(Puppet::Error, 'Only include version or source url.')
    end
  end
end
