module VimPK
  class Update
    include VimPK::Colorizer

    def self.run
      new.update
    end

    def initialize(path = "~/.vim/pack")
      @before = Time.now
      @pack_dir = File.expand_path(path)
      @updates = Queue.new
      @output = Queue.new
      @pool = ThreadPool.new
      @dirs = Dir.glob(File.join(@pack_dir, "*", "{start,opt}", "*", ".git")).sort
      @basenames = @dirs.map { |dir| File.basename(File.dirname(dir)) }
      @longest_name = @basenames.map(&:length).max
    end

    def format_name(name)
      name.rjust(@longest_name)
    end

    def update
      puts "Updating #{@dirs.size} plugins in #{@pack_dir}"

      jobs = @dirs.map do |git_dir|
        plugin_dir = File.dirname(git_dir)
        @pool.schedule Job.new(plugin_dir, @updates, @output)
      end

      @pool.shutdown
      @output.close

      while (message = @output.pop)
        case message
        when String
          Kernel.puts message
        when Hash
          basename = message.keys.first
          message = message.values.first
          message = case message
          when "Updated!" then colorize(message, color: :green)
          when "Already up to date." then colorize(message, color: :blue)
          else message
          end
          puts "#{format_name(basename)}: #{message}"
        end
      end

      puts
      puts colorize("Done updating #{jobs.size} plugins. Took #{Time.now - @before} seconds.")

      if @updates.size.nonzero?
        print "Display diffs? (Y/n) "

        answer = $stdin.getch

        if answer.downcase == "y" || answer == "\r"
          puts
          puts "Displaying diffs…"

          @updates.size.times do
            update = @updates.pop
            next if update[:log].empty?
            puts update[:log].lines.map { |line| "#{format_name(update[:basename])}: #{colorize_diff line}" }.join
          end
        end
      end
    end
  end
end
