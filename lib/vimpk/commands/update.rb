module VimPK
  module Commands
    class Update
      include VimPK::Colorizer

      attr_reader :jobs, :logs, :plugins

      def initialize(options)
        @pack_dir = File.expand_path(options.path)
        @logs = Queue.new
        @progress = Queue.new
        @manifest_updates = Queue.new
        @pool = ThreadPool.new
        @plugins = Dir.glob(File.join(@pack_dir, "*", "{start,opt}", "*", ".git")).sort.map(&File.method(:dirname))
        @jobs = []
        @manifest = Manifest.new(@pack_dir)
      end

      def call
        display = ProgressDisplay.new(@plugins)
        display.start

        # Start progress monitor thread
        progress_thread = Thread.new do
          while (update = @progress.pop)
            display.update(update[:name], update[:status])
          end
        end

        @jobs = @plugins.map do |dir|
          @pool.schedule Job.new(dir, @logs, progress: @progress, manifest_updates: @manifest_updates)
        end

        @pool.shutdown
        @progress.close
        progress_thread.join
        display.finish

        @logs.close
        @manifest_updates.close

        update_manifest
      end

      private

      def update_manifest
        now = Time.now.utc.iso8601

        while (update = @manifest_updates.pop)
          name = update[:name]
          dir = update[:dir]

          # Extract pack and type from path
          # Path format: pack_dir/pack/type/name
          type = File.basename(File.dirname(dir))
          pack = File.basename(File.dirname(File.dirname(dir)))

          if @manifest.exists?(name)
            # Update existing entry
            @manifest.update(name, {
              branch: update[:branch],
              commit: update[:commit],
              updated_at: now
            })
          else
            # Auto-fix: add missing plugin to manifest
            @manifest.add(name, {
              remote_url: update[:remote_url],
              branch: update[:branch],
              commit: update[:commit],
              pack: pack,
              type: type,
              installed_at: now,
              updated_at: now
            })
          end
        end

        @manifest.save
      end
    end
  end
end
