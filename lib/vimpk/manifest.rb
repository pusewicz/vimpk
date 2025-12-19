# frozen_string_literal: true

require "json"
require "time"

module VimPK
  class Manifest
    FILENAME = "manifest.json"

    attr_reader :path

    def initialize(path)
      @path = path
      @file_path = File.join(path, FILENAME)
      @data = load
    end

    def load
      return {} unless File.exist?(@file_path)

      JSON.parse(File.read(@file_path))
    rescue JSON::ParserError
      {}
    end

    def save
      sorted_data = @data.sort.to_h
      File.write(@file_path, JSON.pretty_generate(sorted_data) + "\n")
    end

    def add(name, data)
      @data[name] = data.transform_keys(&:to_s)
    end

    def remove(name)
      @data.delete(name)
    end

    def update(name, new_data)
      return unless @data.key?(name)

      @data[name] = @data[name].merge(new_data.transform_keys(&:to_s))
    end

    def get(name)
      @data[name]
    end

    def exists?(name)
      @data.key?(name)
    end

    def find_by_remote(url)
      normalized_url = normalize_url(url)
      @data.find { |_name, data| normalize_url(data["remote_url"]) == normalized_url }
    end

    def all
      @data
    end

    def each(&block)
      @data.each(&block)
    end

    def size
      @data.size
    end

    def empty?
      @data.empty?
    end

    private

    def normalize_url(url)
      return nil if url.nil?

      # Normalize git URLs to a common format for comparison
      # Remove trailing .git, handle both https and git@ formats
      url = url.strip.downcase
      url = url.sub(/\.git\z/, "")
      url = url.sub(%r{\Agit@github\.com:}, "https://github.com/")
      url = url.sub(%r{\Agit://github\.com/}, "https://github.com/")
      url
    end
  end
end
