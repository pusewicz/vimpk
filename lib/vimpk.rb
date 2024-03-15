# frozen_string_literal: true

require "io/console"
require "etc"

require_relative "vimpk/version"

Thread.abort_on_exception = true

module VimPK
  class Error < StandardError; end

  autoload :CLI, "vimpk/cli"
  autoload :ThreadPool, "vimpk/thread_pool"
  autoload :Job, "vimpk/job"
  autoload :Colorizer, "vimpk/colorizer"
  autoload :Update, "vimpk/update"
end
