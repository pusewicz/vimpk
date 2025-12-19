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
        @manifest = Manifest.new(@path)
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
          new_pack = @pack || current_pack
          new_type = @type || current_type
          @dest = File.join(@path, new_pack, new_type, @name)

          if File.exist?(dest)
            raise ArgumentError, "Package #{@name} already exists in #{dest}."
          else
            FileUtils.mkdir_p(File.dirname(dest))
          end

          FileUtils.mv(source, dest)
          update_manifest(new_pack, new_type)
        end
      end

      private

      def update_manifest(pack, type)
        @manifest.update(@name, {
          pack: pack,
          type: type,
          updated_at: Time.now.utc.iso8601
        })
        @manifest.save
      end
    end
  end
end
