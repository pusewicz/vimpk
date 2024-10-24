# frozen_string_literal: true
# rbs_inline: enabled

require "fileutils"

module VimPK
  module Commands
    class List
      attr_reader :dest

      def initialize(options)
        @path = options.path
        @pack = options.pack || "*"
        @type = options.type || "{start,opt}"
      end

      def call
        pattern = File.join(@path, @pack, @type, "*")
        glob = Dir.glob(pattern)

        raise PackageNotFoundError, "No packages were found in #{pattern}." if glob.empty?

        glob
      end
    end
  end
end
