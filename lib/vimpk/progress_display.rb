# frozen_string_literal: true

module VimPK
  class ProgressDisplay
    include Colorizer

    STATUSES = {
      pending: {symbol: "⋯", color: :blue, text: "Pending"},
      fetching: {symbol: "↻", color: :blue, text: "Fetching"},
      checking: {symbol: "🔍", color: :blue, text: "Checking"},
      updating: {symbol: "⬇", color: :yellow, text: "Updating"},
      updated: {symbol: "✓", color: :green, text: "Updated"},
      up_to_date: {symbol: "•", color: :green, text: "Up to date"}
    }

    def initialize(plugins)
      @plugins = plugins.map { |path| File.basename(path) }.sort_by(&:downcase)
      @statuses = {}
      @plugins.each { |name| @statuses[name] = :pending }
      @max_name_length = @plugins.map(&:length).max
      @started = false
      @use_colors = !ENV["NO_COLOR"]
    end

    def start
      return if @started
      @started = true

      # Print initial list
      @plugins.each do |name|
        puts format_status_line(name)
      end
    end

    def update(name, status)
      return unless @statuses.key?(name)

      @statuses[name] = status

      # Calculate which line to update (0-indexed from current position)
      plugin_index = @plugins.index(name)
      lines_to_move_up = @plugins.size - plugin_index

      # Move cursor up to the plugin's line
      print "\e[#{lines_to_move_up}A" if lines_to_move_up > 0

      # Clear line and reprint without newline
      print "\r\e[K"
      print format_status_line(name)

      # Move cursor back down to home position (one line past the last plugin)
      print "\e[#{lines_to_move_up}B" if lines_to_move_up > 0
    end

    def finish
      # Move cursor to end
      puts
    end

    def summary
      updated_count = @statuses.values.count { |s| s == :updated }
      up_to_date_count = @statuses.values.count { |s| s == :up_to_date }

      {updated: updated_count, up_to_date: up_to_date_count}
    end

    private

    def format_status_line(name)
      status = @statuses[name]
      status_info = STATUSES[status]

      formatted_name = name.ljust(@max_name_length)
      symbol = status_info[:symbol]
      text = status_info[:text]

      if @use_colors
        colored_text = colorize(text, color: status_info[:color])
        "#{formatted_name}  [#{symbol}] #{colored_text}"
      else
        "#{formatted_name}  [#{symbol}] #{text}"
      end
    end
  end
end
