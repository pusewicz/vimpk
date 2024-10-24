# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  module Git
    module_function

    class GitError < StandardError
      attr_reader :output #: String

      # @rbs message: String
      # @rbs output: String
      def initialize(message, output) #: void
        super(message)
        @output = output
      end
    end

    # @rbs dir: String
    def branch(dir: Dir.pwd) #: String
      command("rev-parse --abbrev-ref HEAD", dir: dir)
    end

    # @rbs branch: String
    # @rbs dir: String
    def log(branch, dir: Dir.pwd) #: String
      command("log -p --full-diff HEAD..origin/#{branch}", dir: dir)
    end

    # @rbs branch: String
    # @rbs dir: String
    def fetch(branch, dir: Dir.pwd) #: String
      command("fetch origin #{branch}", dir: dir)
    end

    # @rbs dir: String -> String
    def pull(dir: Dir.pwd) #: String
      command("pull --rebase", dir: dir)
    end

    # @rbs source: String
    # @rbs dest: String
    # @rbs dir: String
    def clone(source, dest, dir: Dir.pwd) #: String
      out = command("clone #{source} #{dest}", dir: dir)
      if $?.exitstatus != 0
        raise GitError.new("Failed to clone #{source} to #{dest}", out)
      end
      out
    end

    # @rbs args: String
    # @rbs dir: String
    def command(args, dir: Dir.pwd) #: String
      IO.popen("git -C #{dir} #{args}", dir: dir, err: [:child, :out]) do |io|
        io.read.chomp
      end
    end
  end
end
