module VimPK
  class Install
    include VimPK::Colorizer

    def initialize(package, path, pack, type)
      @package = package || abort("Error: package name is required")
      @path = path
      @pack = pack
      @type = type
      @dest = File.join(@path, @pack, @type, File.basename(@package))
      @source = "https://github.com/#{package}.git"
      @git = Git
    end

    def format_name(name)
      name.rjust(@longest_name)
    end

    def call
      abort "Error: Package already exists at #{@dest}" if File.exist?(@dest)
      time = Time.now
      puts "Installing #{@package} to #{@dest}"

      Git.clone(@source, @dest, dir: @path)

      puts colorize("Installed #{@package} to #{@dest}. Took #{Time.now - time} seconds.", color: :green)
    rescue Git::GitError => e
      puts colorize("Error: #{e.message}", color: :red)
      abort e.output.lines.map { |line| "  #{line}" }.join
    end
  end
end
