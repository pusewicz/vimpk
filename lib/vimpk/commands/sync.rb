module VimPK
  module Commands
    class Sync
      include VimPK::Colorizer

      def initialize(options)
        @pack_dir = File.expand_path(options.path)
        @manifest = Manifest.new(@pack_dir)
      end

      def call
        plugins_on_disk = discover_plugins
        existing_names = @manifest.all.keys

        added = []
        updated = []
        removed = []

        # Add/update plugins found on disk
        plugins_on_disk.each do |plugin|
          name = plugin[:name]

          if @manifest.exists?(name)
            # Update existing entry
            @manifest.update(name, {
              branch: plugin[:branch],
              commit: plugin[:commit],
              pack: plugin[:pack],
              type: plugin[:type],
              updated_at: plugin[:updated_at]
            })
            updated << name
          else
            # Add new entry
            @manifest.add(name, plugin)
            added << name
          end
        end

        # Remove plugins no longer on disk
        disk_names = plugins_on_disk.map { |p| p[:name] }
        existing_names.each do |name|
          unless disk_names.include?(name)
            @manifest.remove(name)
            removed << name
          end
        end

        @manifest.save

        {added: added, updated: updated, removed: removed}
      end

      private

      def discover_plugins
        now = Time.now.utc.iso8601
        plugins = []

        Dir.glob(File.join(@pack_dir, "*", "{start,opt}", "*", ".git")).sort.each do |git_dir|
          dir = File.dirname(git_dir)
          name = File.basename(dir)
          type = File.basename(File.dirname(dir))
          pack = File.basename(File.dirname(File.dirname(dir)))

          plugins << {
            name: name,
            remote_url: Git.remote_url(dir: dir),
            branch: Git.branch(dir: dir),
            commit: Git.commit(dir: dir),
            pack: pack,
            type: type,
            installed_at: now,
            updated_at: now
          }
        end

        plugins
      end
    end
  end
end
