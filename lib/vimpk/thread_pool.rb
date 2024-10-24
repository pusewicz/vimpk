# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  class ThreadPool
    def initialize(size = Etc.nprocessors * 2)
      Thread.abort_on_exception = true
      @size = size
      @jobs = Queue.new
      @workers = Array.new(size) do
        Thread.new(@jobs) do |jobs|
          while (job = jobs.pop)
            job.call
          end

          Thread.exit
        end
      end
    end

    def schedule(job)
      @jobs << job
    end

    def shutdown
      @jobs.close
      @workers.each(&:join)
    end
  end
end
