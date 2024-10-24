# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  module Colorizer
    private

    def colorize_diff(line)
      return line if ENV["NO_COLOR"]
      case line
      when /^diff --git/
        "\e[1;34m#{line}\e[0m"
      when /^index/
        "\e[1;36m#{line}\e[0m"
      when /^---/
        "\e[1;31m#{line}\e[0m"
      when /^\+\+\+/
        "\e[1;32m#{line}\e[0m"
      when /^@@/
        "\e[1;33m#{line}\e[0m"
      when /^\+/
        "\e[1;32m#{line}\e[0m"
      when /^-/
        "\e[1;31m#{line}\e[0m"
      else
        line
      end
    end

    def colorize(text, color: :green)
      return text if ENV["NO_COLOR"]
      case color
      when :green
        "\e[32m#{text}\e[0m"
      when :red
        "\e[31m#{text}\e[0m"
      when :blue
        "\e[34m#{text}\e[0m"
      when :yellow
        "\e[33m#{text}\e[0m"
      else
        raise ArgumentError, "Unknown color: #{color}"
      end
    end
  end
end
