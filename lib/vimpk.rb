# frozen_string_literal: true

require_relative "vimpk/version"

module VimPK
  class Error < StandardError; end

  autoload :CLI, "vimpk/cli"
end
