module VimPK
  class Install
    include VimPK::Colorizer

    PackageExistsError = Class.new(StandardError)

    attr_reader :dest

    def initialize(package, path, pack, type)
      @package = package || raise(ArgumentError, "Package name is required")
      @path = path
      @pack = pack
      @type = type
      @dest = File.join(@path, @pack, @type, File.basename(@package))
      @source = "https://github.com/#{package}.git"
      @git = Git
    end

    def call
      raise PackageExistsError, "Package #{@package} already exists at #{@dest}" if File.exist?(@dest)

      Git.clone(@source, @dest, dir: @path)
    end
  end
end
