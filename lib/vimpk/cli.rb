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
      abort help_message
    end

    def call
      if @command
        send(@command, *@argv)
        exit 0
      else
        puts @parser.parser
      end
    end

    private

    def help_message
      "Use --help for usage information"
    end

    def determine_command
      return nil if @argv.empty?

      name = @argv.shift&.downcase
      case name
      when "i", "install"
        :install_command
      when "l", "list"
        :list_command
      when "mv", "move"
        :move_command
      when "u", "update"
        :update_command
      when "rm", "remove"
        :remove_command
      else
        warn colorize("Unknown command: #{name}", color: :yellow)
        abort help_message
      end
    end

    def list_command
      command = Commands::List.new(@options)
      list = command.call
      puts list.sort_by(&:downcase)
    end

    def install_command(package = nil)
      time = Time.now
      command = Commands::Install.new(package, @options)
      puts "Installing #{package} to #{command.dest}…"
      command.call
      puts colorize("Installed #{package} to #{command.dest}. Took #{Time.now - time} seconds.", color: :green)
    rescue Git::GitError => e
      warn colorize("Error: #{e.message}", color: :yellow)
      abort e.output.lines.map { |line| "  #{line}" }.join
    rescue Commands::Install::PackageExistsError => e
      abort colorize("Error: #{e.message}", color: :red)
    rescue ArgumentError => e
      abort colorize("Error: #{e.message}", color: :red)
    end

    def move_command(name = nil)
      command = Commands::Move.new(name, @options)
      command.call
      puts colorize("Moved #{name} to #{command.dest}.", color: :green)
    rescue Commands::Move::PackageNotFoundError, Commands::Move::MultiplePackagesFoundError, ArgumentError => e
      abort colorize(e.message, color: :red)
    end

    def update_command
      command = Commands::Update.new(@options)
      puts "Updating #{command.plugins.size} packages in #{@options[:path]}…"
      start_time = Time.now
      command.call

      statuses = {}

      while (log = command.logs.pop)
        basename = log[:basename]
        statuses[basename] = log[:log]
      end

      basenames = command.plugins.map { |dir| File.basename(dir) }.sort_by(&:downcase)

      max_name_length = statuses.keys.map(&:length).max

      basenames.each do |basename|
        if statuses[basename]
          formatted_name = basename.rjust(max_name_length)
          formatted_status = colorize("Updated!", color: :green)
          puts "#{formatted_name}: #{formatted_status}"
        end
      end

      if statuses.size < command.jobs.size
        puts "The remaining #{command.jobs.size - statuses.size} plugins are up to date."
      end

      puts colorize("Finished updating #{command.jobs.size} plugins. Took #{Time.now - start_time} seconds.")

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
      Commands::Remove.new(name, @options).call

      puts colorize("Package #{name} removed.", color: :green)
    rescue ArgumentError, VimPK::Remove::PackageNotFoundError => e
      abort colorize(e.message, color: :red)
    end
  end
end
