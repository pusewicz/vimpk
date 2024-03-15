require "fileutils"

module VimPK
  class Remove
    PackageNotFound = Class.new(StandardError)

    def initialize(name, path)
      @name = name || raise(ArgumentError, "Package name is required")
      @path = path
    end

    def call
      glob = Dir.glob(File.join(@path, "*", "{start,opt}", @name))

      if glob.empty?
        raise PackageNotFound, "Package #{@name} not found in #{@path}."
      else
        glob.each do |dir|
          FileUtils.rm_rf(dir)
        end
      end
    end
  end
end
