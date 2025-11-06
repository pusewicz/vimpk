module VimPK
  module Commands
    class Update
      include VimPK::Colorizer

      attr_reader :jobs, :logs, :plugins

      def initialize(options)
        @pack_dir = File.expand_path(options.path)
        @logs = Queue.new
        @progress = Queue.new
        @pool = ThreadPool.new
        @plugins = Dir.glob(File.join(@pack_dir, "*", "{start,opt}", "*", ".git")).sort.map(&File.method(:dirname))
        @jobs = []
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
          @pool.schedule Job.new(dir, @logs, progress: @progress)
        end

        @pool.shutdown
        @progress.close
        progress_thread.join
        display.finish

        @logs.close
      end
    end
  end
end
