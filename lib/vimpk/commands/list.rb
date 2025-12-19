module VimPK
  module Commands
    class List
      def initialize(options)
        @path = options.path
        @pack = options.pack
        @type = options.type
        @manifest = Manifest.new(@path)
      end

      def call
        results = []

        @manifest.each do |name, data|
          # Apply filters
          next if @pack && data["pack"] != @pack
          next if @type && data["type"] != @type

          # Construct the path from manifest data
          path = File.join(@path, data["pack"], data["type"], name)
          results << path
        end

        raise PackageNotFoundError, "No packages found." if results.empty?

        results
      end
    end
  end
end
