# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  module Commands
    class Install
      include VimPK::Colorizer

      attr_reader :dest

      def initialize(package, options)
        @package = package || raise(ArgumentError, "Package name is required")
        @path = options.path
        @pack = options.pack || options.default_pack
        @type = options.type || options.default_type
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
end
