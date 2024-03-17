# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "vimpk"
require "fileutils"

require "minitest/autorun"

ENV["NO_COLOR"] = "1"

def using_pack_path
  Dir.mktmpdir do |dir|
    FileUtils.cp_r("test/fixtures/vim/pack/.", dir)
    yield dir
  end
end
