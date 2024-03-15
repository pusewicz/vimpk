# frozen_string_literal: true

module VimPK
  class CLI
    include Colorizer

    def initialize(args)
      @args = args
      @parser = VimPK::Options.new(args)
      @options = @parser.options
      @command = determine_command
    end

    def call
      if @command
        send(@command, *@args)
      else
        puts @parser.parser
      end
    end

    def determine_command
      return nil if @args.empty?

      case @args.shift&.downcase
      when "i", "install"
        :install_command
      when "u", "update"
        :update_command
      when "rm", "remove"
        :remove_command
      else
        raise "Unknown command: #{name}"
      end
    end

    def install_command(package = nil)
      VimPK::Install.new(package, @options[:path], @options[:pack], @options[:type]).call
    end

    def update_command
      update = VimPK::Update.new(@options[:path])
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
      VimPK::Remove.new(name, @options[:path]).call
    rescue ArgumentError, VimPK::Remove::PackageNotFound => e
      abort colorize(e.message, color: :red)
    end
  end
end
