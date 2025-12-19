module VimPK
  class Job
    def initialize(dir, logs, progress: nil, manifest_updates: nil)
      @dir = dir
      @basename = File.basename(dir)
      @logs = logs
      @progress = progress
      @manifest_updates = manifest_updates
    end

    def call
      report_progress(:fetching)
      branch = Git.branch(dir: @dir)
      Git.fetch(branch, dir: @dir)

      report_progress(:checking)
      log = Git.log(branch, dir: @dir)

      if log.empty?
        report_progress(:up_to_date)
        # Still report manifest update for auto-fix (plugin on disk but not in manifest)
        report_manifest_update(branch)
      else
        @logs << {basename: @basename, log: log}

        report_progress(:updating)
        Git.pull(dir: @dir)
        report_progress(:updated)
        report_manifest_update(branch)
      end
    end

    private

    def report_progress(status)
      @progress&.push({name: @basename, status: status})
    end

    def report_manifest_update(branch)
      @manifest_updates&.push({
        name: @basename,
        dir: @dir,
        branch: branch,
        commit: Git.commit(dir: @dir),
        remote_url: Git.remote_url(dir: @dir)
      })
    end
  end
end
