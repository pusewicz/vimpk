# frozen_string_literal: true

module VimPK
  class CLI
    include Colorizer

    attr_reader :command

    def initialize(argv)
      @argv = argv
      @parser = Options.new(argv)
      @options = @parser.parse
      @command = determine_command
    rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
      warn e.message
      abort "Use --help for usage information"
    end

    def call
      if @command
        send(@command, *@argv)
      else
        puts @parser.parser
      end
    end

    def determine_command
      return nil if @argv.empty?

      name = @argv.shift&.downcase
      case name
      when "i", "install"
        :install_command
      when "mv", "move"
        :move_command
      when "u", "update"
        :update_command
      when "rm", "remove"
        :remove_command
      else
        warn colorize("Unknown command: #{name}", color: :red)
        abort "Use --help for usage information"
      end
    end

    def install_command(package = nil)
      time = Time.now
      install = Install.new(package, @options[:path], @options[:pack], @options[:type])
      puts "Installing #{package} to #{install.dest}…"
      install.call
      puts colorize("Installed #{package} to #{install.dest}. Took #{Time.now - time} seconds.", color: :green)
    rescue Git::GitError => e
      warn colorize("Error: #{e.message}", color: :red)
      abort e.output.lines.map { |line| "  #{line}" }.join
    rescue Install::PackageExistsError => e
      warn colorize("Error: #{e.message}", color: :red)
    rescue ArgumentError => e
      warn colorize("Error: #{e.message}", color: :red)
    end

    def move_command(name = nil)
      move = Move.new(name, @options[:path], @options[:pack], @options[:type])
      move.call
      puts colorize("Moved #{name} to #{move.dest}.", color: :green)
    rescue Move::PackageNotFoundError, Move::MultiplePackagesFoundError, ArgumentError => e
      abort colorize(e.message, color: :red)
    end

    def update_command
      update = Update.new(@options[:path])
      puts "Updating #{update.plugins.size} packages in #{@options[:path]}…"
      start_time = Time.now
      update.call

      statuses = {}

      while (log = update.logs.pop)
        basename = log[:basename]
        statuses[basename] = log[:log]
      end

      basenames = update.plugins.map { |dir| File.basename(dir) }.sort_by(&:downcase)

      max_name_length = statuses.keys.map(&:length).max

      basenames.each do |basename|
        if statuses[basename]
          formatted_name = basename.rjust(max_name_length)
          formatted_status = colorize("Updated!", color: :green)
          puts "#{formatted_name}: #{formatted_status}"
        end
      end

      if statuses.size < update.jobs.size
        puts "The remaining #{update.jobs.size - statuses.size} plugins are up to date."
      end

      puts colorize("Finished updating #{update.jobs.size} plugins. Took #{Time.now - start_time} seconds.")

      if statuses.size.nonzero?
        print "Display diffs? (Y/n) "

        answer = $stdin.getch

        if answer.downcase == "y" || answer == "\r"
          puts
          puts "Displaying diffs…"

          statuses.each do |basename, status|
            puts status.lines.map { |line| "#{basename}: #{colorize_diff line}" }.join
          end
        end
      end
    end

    def remove_command(name = nil)
      Remove.new(name, @options[:path]).call

      puts colorize("Package #{name} removed.", color: :green)
    rescue ArgumentError, VimPK::Remove::PackageNotFoundError => e
      abort colorize(e.message, color: :red)
    end
  end
end
