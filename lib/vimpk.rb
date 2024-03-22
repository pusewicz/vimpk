# frozen_string_literal: true

require "io/console"
require "etc"

require_relative "vimpk/version"

module VimPK
  class Error < StandardError; end

  autoload :CLI, "vimpk/cli"
  autoload :Commands, "vimpk/commands"
  autoload :Colorizer, "vimpk/colorizer"
  autoload :Git, "vimpk/git"
  autoload :Job, "vimpk/job"
  autoload :Options, "vimpk/options"
  autoload :ThreadPool, "vimpk/thread_pool"
end
