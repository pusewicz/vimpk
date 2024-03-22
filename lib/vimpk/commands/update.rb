module VimPK
  module Commands
    class Update
      include VimPK::Colorizer

      attr_reader :jobs, :logs, :plugins

      def initialize(options)
        @pack_dir = File.expand_path(options.path)
        @logs = Queue.new
        @pool = ThreadPool.new
        @plugins = Dir.glob(File.join(@pack_dir, "*", "{start,opt}", "*", ".git")).sort.map(&File.method(:dirname))
        @jobs = []
      end

      def call
        @jobs = @plugins.map do |dir|
          @pool.schedule Job.new(dir, @logs)
        end

        @pool.shutdown
        @logs.close
      end
    end
  end
end
