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
        @name = File.basename(@package)
        @dest = File.join(@path, @pack, @type, @name)
        @source = "https://github.com/#{package}.git"
        @manifest = Manifest.new(@path)
      end

      def call
        check_for_duplicates
        raise PackageExistsError, "Package #{@package} already exists at #{@dest}" if File.exist?(@dest)

        Git.clone(@source, @dest, dir: @path)
        add_to_manifest
      end

      private

      def check_for_duplicates
        # Check if same name exists with same remote URL
        if @manifest.exists?(@name)
          existing = @manifest.get(@name)
          if same_remote?(existing["remote_url"], @source)
            raise PackageExistsError, "Package #{@name} is already installed"
          end
          # Allow same name from different remote (forks)
        end

        # Check if same remote URL exists under different name
        existing = @manifest.find_by_remote(@source)
        if existing
          raise PackageExistsError, "Package from #{@source} is already installed as '#{existing[0]}'"
        end
      end

      def same_remote?(url1, url2)
        normalize_url(url1) == normalize_url(url2)
      end

      def normalize_url(url)
        return nil if url.nil?

        url = url.strip.downcase
        url = url.sub(/\.git\z/, "")
        url = url.sub(%r{\Agit@github\.com:}, "https://github.com/")
        url = url.sub(%r{\Agit://github\.com/}, "https://github.com/")
        url
      end

      def add_to_manifest
        now = Time.now.utc.iso8601
        @manifest.add(@name, {
          remote_url: @source,
          branch: Git.branch(dir: @dest),
          commit: Git.commit(dir: @dest),
          pack: @pack,
          type: @type,
          installed_at: now,
          updated_at: now
        })
        @manifest.save
      end
    end
  end
end
