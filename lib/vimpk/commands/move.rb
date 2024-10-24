# frozen_string_literal: true
# rbs_inline: enabled

require "fileutils"

module VimPK
  module Commands
    class Move
      attr_reader :dest

      def initialize(name, options)
        raise ArgumentError, "New pack or type is required" unless options.pack || options.type
        @name = name || raise(ArgumentError, "Package name is required")
        @path = options.path
        @pack = options.pack
        @type = options.type
      end

      def call
        glob = Dir.glob(File.join(@path, "*", "{start,opt}", @name))

        if glob.empty?
          raise PackageNotFoundError, "Package #{@name} not found in #{@path}."
        elsif glob.size > 1
          raise MultiplePackagesFoundError, "Multiple packages #{@name} found in #{glob.join(" and ")}."
        else
          source = glob.first
          current_type = File.basename(File.dirname(source))
          current_pack = File.basename(File.dirname(File.dirname(source)))
          @dest = File.join(@path, @pack || current_pack, @type || current_type, @name)

          if File.exist?(dest)
            raise ArgumentError, "Package #{@name} already exists in #{dest}."
          else
            FileUtils.mkdir_p(File.dirname(dest))
          end

          FileUtils.mv(source, dest)
        end
      end
    end
  end
end
