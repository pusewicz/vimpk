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
    rescue PackageExistsError => e
      abort colorize("Error: #{e.message}", color: :red)
    rescue ArgumentError => e
      abort colorize("Error: #{e.message}", color: :red)
    end

    def move_command(name = nil)
      command = Commands::Move.new(name, @options)
      command.call
      puts colorize("Moved #{name} to #{command.dest}.", color: :green)
    rescue PackageNotFoundError, MultiplePackagesFoundError, ArgumentError => e
      abort colorize(e.message, color: :red)
    end

    def update_command
      command = Commands::Update.new(@options)
      puts "Updating #{command.plugins.size} packages in #{@options[:path]}…"
      puts
      start_time = Time.now
      command.call

      # Collect update logs
      statuses = {}
      while (log = command.logs.pop)
        basename = log[:basename]
        statuses[basename] = log[:log]
      end

      # Show summary
      puts
      puts colorize("Finished updating #{command.plugins.size} plugins. Took #{(Time.now - start_time).round(2)} seconds.", color: :green)

      if statuses.any?
        puts colorize("#{statuses.size} plugin(s) updated, #{command.plugins.size - statuses.size} up to date.", color: :green)
      else
        puts colorize("All plugins are up to date.", color: :green)
      end

      # Optionally display diffs
      if statuses.any?
        puts
        print "Display diffs? (Y/n) "

        answer = $stdin.getch

        if answer.downcase == "y" || answer == "\r"
          puts
          puts "Displaying diffs…"

          options = ENV["NO_COLOR"] ? [] : %w[--use-color -R]

          IO.popen(["less", *options], "w") do |io|
            statuses.each do |basename, status|
              status.lines.each do |line|
                io.print "#{basename}: #{colorize_diff line}"
              end
            end
          end
        else
          puts
        end
      end
    end

    def remove_command(*names)
      names.each do |name|
        Commands::Remove.new(name, @options).call

        puts colorize("Package #{name} removed.", color: :green)
      end
    rescue ArgumentError, PackageNotFoundError => e
      abort colorize(e.message, color: :red)
    end
  end
end
