module VimPK
  module Git
    module_function

    class GitError < StandardError
      attr_reader :output

      def initialize(message, output)
        super(message)
        @output = output
      end
    end

    def branch(dir: Dir.pwd)
      command("rev-parse --abbrev-ref HEAD", dir: dir)
    end

    def log(branch, dir: Dir.pwd)
      command("log -p --full-diff HEAD..origin/#{branch}", dir: dir)
    end

    def fetch(branch, dir: Dir.pwd)
      command("fetch origin #{branch}", dir: dir)
    end

    def pull(dir: Dir.pwd)
      command("pull --rebase", dir: dir)
    end

    def clone(source, dest, dir: Dir.pwd)
      out = command("clone #{source} #{dest}", dir: dir)
      if $?.exitstatus != 0
        raise GitError.new("Failed to clone #{source} to #{dest}", out)
      end
    end

    def command(args, dir: Dir.pwd)
      IO.popen("git -C #{dir} #{args}", dir: dir, err: [:child, :out]) do |io|
        io.read.chomp
      end
    end
  end
end
