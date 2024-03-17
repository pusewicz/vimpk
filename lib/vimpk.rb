# frozen_string_literal: true

require "io/console"
require "etc"

require_relative "vimpk/version"

Thread.abort_on_exception = true

module VimPK
  class Error < StandardError; end

  autoload :CLI, "vimpk/cli"
  autoload :Colorizer, "vimpk/colorizer"
  autoload :Git, "vimpk/git"
  autoload :Install, "vimpk/install"
  autoload :Job, "vimpk/job"
  autoload :List, "vimpk/list"
  autoload :Move, "vimpk/move"
  autoload :Options, "vimpk/options"
  autoload :Remove, "vimpk/remove"
  autoload :ThreadPool, "vimpk/thread_pool"
  autoload :Update, "vimpk/update"
end
