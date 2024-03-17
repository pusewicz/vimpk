# frozen_string_literal: true

require "optparse"

module VimPK
  class Options
    attr_reader :options, :parser

    DEFAULT_PATH = File.expand_path("~/.vim/pack").freeze
    DEFAULT_TYPE = "start"
    DEFAULT_PACK = "plugins"

    DefaultOptions = Struct.new(:path, :pack, :type, :default_pack, :default_type)

    def initialize(argv)
      @argv = argv
      @options = DefaultOptions.new(DEFAULT_PATH, nil, nil, DEFAULT_PACK, DEFAULT_TYPE)

      @parser = OptionParser.new do |parser|
        parser.banner = "Usage: #{parser.program_name} [options] [command [options]"
        parser.separator ""
        parser.separator "Options:"

        parser.on("--pack=PATH", String, "Name of the pack (#{DEFAULT_PACK})") do |pack|
          @options[:pack] = pack
        end

        parser.on("--path=PATH", String, "Path to Vim's pack directory (#{DEFAULT_PATH})") do |path|
          path = File.expand_path(path)
          unless File.directory?(path)
            abort("Error: #{path} is not a directory")
          end
          @options[:path] = path
        end

        parser.on("--opt", "Install package as an optional plugin") do
          @options[:type] = "opt"
        end

        parser.on("--start", "Install package as a start plugin (default)") do
          @options[:type] = "start"
        end

        parser.on("-h", "--help", "Show this help message") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "Show version") do
          puts VimPK::VERSION
          exit
        end

        parser.separator ""
        parser.separator "Commands:"
        parser.separator "        i|install REPO/NAME [--opt|--start] [--pack=PATH] [--path=PATH] Install a package"
        parser.separator "        l|list [--opt|--start] [--pack=PATH] [--path=PATH]              List packages"
        parser.separator "        mv|move NAME [--opt|--start] [--pack=PATH]                      Move a package"
        parser.separator "        u|update                                                        Update all packages"
        parser.separator "        rm|remove NAME                                                  Remove all occurrences of a package"
      end
    end

    def parse
      @parser.permute!(@argv)
      @options
    end
  end
end
