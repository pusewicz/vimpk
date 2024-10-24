# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  class Job
    def initialize(dir, logs)
      @dir = dir
      @basename = File.basename(dir)
      @logs = logs
      @git = Git
    end

    def call
      branch = Git.branch(dir: @dir)
      Git.fetch(branch, dir: @dir)
      log = Git.log(branch, dir: @dir)

      unless log.empty?
        @logs << {basename: @basename, log: log}

        Git.pull(dir: @dir)
      end
    end
  end
end
