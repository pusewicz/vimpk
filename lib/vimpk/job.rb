module VimPK
  class Job
    def initialize(dir, updates, output)
      @dir = dir
      @basename = File.basename(dir)
      @updates = updates
      @output = output
    end

    def call
      branch = git("rev-parse --abbrev-ref HEAD", dir: @dir)
      git("fetch origin #{branch}", dir: @dir)
      log = git("log -p --full-diff HEAD..origin/#{branch}", dir: @dir)

      if log.empty?
        puts("Already up to date.")
      else
        git("pull --rebase", dir: @dir)
        @updates << {basename: @basename, log: log}
        puts "Updated!"
      end
    end

    def puts(message = "\n")
      @output << {@basename => message}
    end

    private

    def git(command, dir:)
      IO.popen("git -C #{dir} #{command}", dir: dir, err: [:child, :out]) { |io| io.read.chomp }
    end
  end
end
