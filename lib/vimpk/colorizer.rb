module VimPK
  module Colorizer
    private

    def colorize_diff(line)
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
      case color
      when :green
        "\e[32m#{text}\e[0m"
      when :red
        "\e[31m#{text}\e[0m"
      when :blue
        "\e[34m#{text}\e[0m"
      end
    end
  end
end
