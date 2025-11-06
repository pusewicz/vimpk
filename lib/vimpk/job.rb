module VimPK
  class Job
    def initialize(dir, logs, progress: nil)
      @dir = dir
      @basename = File.basename(dir)
      @logs = logs
      @progress = progress
      @git = Git
    end

    def call
      report_progress(:fetching)
      branch = Git.branch(dir: @dir)
      Git.fetch(branch, dir: @dir)

      report_progress(:checking)
      log = Git.log(branch, dir: @dir)

      if log.empty?
        report_progress(:up_to_date)
      else
        @logs << {basename: @basename, log: log}

        report_progress(:updating)
        Git.pull(dir: @dir)
        report_progress(:updated)
      end
    end

    private

    def report_progress(status)
      @progress&.push({name: @basename, status: status})
    end
  end
end
