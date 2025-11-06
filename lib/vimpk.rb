# frozen_string_literal: true

require "io/console"
require "etc"

require_relative "vimpk/version"

module VimPK
  Error = Class.new(StandardError)
  PackageExistsError = Class.new(Error)
  PackageNotFoundError = Class.new(Error)
  MultiplePackagesFoundError = Class.new(Error)

  autoload :CLI, "vimpk/cli"
  autoload :Commands, "vimpk/commands"
  autoload :Colorizer, "vimpk/colorizer"
  autoload :Git, "vimpk/git"
  autoload :Job, "vimpk/job"
  autoload :Options, "vimpk/options"
  autoload :ProgressDisplay, "vimpk/progress_display"
  autoload :ThreadPool, "vimpk/thread_pool"
end
