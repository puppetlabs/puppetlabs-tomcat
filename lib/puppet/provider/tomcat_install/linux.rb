require 'fileutils'
require 'rubygems/package'
require 'zlib'
require 'open-uri'
require 'open_uri_redirections'

Puppet::Type.type(:tomcat_install).provide(:linux) do
  def initialize(value={})
    super(value)
  end

  def get_tomcat_version(catalina_home)
    return nil unless File.exist?("#{catalina_home}/RELEASE-NOTES")

    version = nil

    File.open("#{catalina_home}/RELEASE-NOTES", 'r').each_line do |li|
      if li[/Version \d{1,2}\.\d{1,2}\.\d{1,2}/]
        version = li[/\d{1,2}\.\d{1,2}\.\d{1,2}/]
        break
      end
    end

    version
  end

  def exists?
    get_tomcat_version(resource[:catalina_home]) == resource[:version]
  end

  def destroy
    FileUtils.rm_r resource[:catalina_home] if Dir.exist?(resource[:catalina_home])
  end

  def create
    destroy

    tomcat_major = resource[:version].split('.')[0]

    tomcat_urls = [
      "https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-#{tomcat_major}/v#{resource[:version]}/bin/apache-tomcat-#{resource[:version]}.tar.gz",
      "https://www-us.apache.org/dist/tomcat/tomcat-#{tomcat_major}/v#{resource[:version]}/bin/apache-tomcat-#{resource[:version]}.tar.gz",
      "https://www.apache.org/dist/tomcat/tomcat-#{tomcat_major}/v#{resource[:version]}/bin/apache-tomcat-#{resource[:version]}.tar.gz",
      "https://archive.apache.org/dist/tomcat/tomcat-#{tomcat_major}/v#{resource[:version]}/bin/apache-tomcat-#{resource[:version]}.tar.gz"
    ].freeze

    FileUtils.mkdir_p resource[:catalina_home]

    tomcat_url_index = -1

    # Download the tomcat zip
    tomcat_urls.each do |url|
      tomcat_url_index += 1

      begin
        open(url, allow_redirections: :all) do |f|
          File.open("#{resource[:catalina_home]}/apache-tomcat-#{resource[:version]}.tar.gz", 'wb') do |file|
            file.puts f.read
          end
          break
        end
      rescue OpenURI::HTTPError
        next
      end
    end

    # UNTAR File
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open("#{resource[:catalina_home]}/apache-tomcat-#{resource[:version]}.tar.gz"))
    tar_extract.rewind # The extract has to be rewinded after every iteration

    tar_extract.each do |entry|
      next unless entry.file?
      entry_name = %r{[^\/]+\/(.+)}.match(entry.full_name)[1]

      FileUtils.mkdir_p(File.dirname("#{resource[:catalina_home]}/#{entry_name}"))
      File.open("#{resource[:catalina_home]}/#{entry_name}", 'wb') do |f|
        f.write(entry.read)
      end
      File.chmod(entry.header.mode, "#{resource[:catalina_home]}/#{entry_name}")
    end

    tar_extract.close

    FileUtils.mkdir_p "#{resource[:catalina_home]}/logs"
    File.delete("#{resource[:catalina_home]}/apache-tomcat-#{resource[:version]}.tar.gz")
    FileUtils.chown_R resource[:user], resource[:group], resource[:catalina_home]
  end
end
