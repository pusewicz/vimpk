# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  def test_valid_command
    assert_equal :install_command, VimPK::CLI.new(["i"]).command
    assert_equal :install_command, VimPK::CLI.new(["install"]).command
    assert_equal :list_command, VimPK::CLI.new(["l"]).command
    assert_equal :list_command, VimPK::CLI.new(["list"]).command
    assert_equal :move_command, VimPK::CLI.new(["mv"]).command
    assert_equal :move_command, VimPK::CLI.new(["move"]).command
    assert_equal :update_command, VimPK::CLI.new(["u"]).command
    assert_equal :update_command, VimPK::CLI.new(["update"]).command
    assert_equal :remove_command, VimPK::CLI.new(["rm"]).command
    assert_equal :remove_command, VimPK::CLI.new(["remove"]).command
  end

  def test_invalid_command
    _out, err = capture_io do
      exception = assert_raises(SystemExit) { VimPK::CLI.new(["foo"]) }
      assert_equal(1, exception.status)
    end

    assert_equal(<<~ERROR, err)
      Unknown command: foo
      Use --help for usage information
    ERROR
  end

  def test_call_version
    out, _err = capture_io do
      exception = assert_raises(SystemExit) { VimPK::CLI.new(["--version"]).call }
      assert_equal(0, exception.status)
    end

    assert_equal("#{VimPK::VERSION}\n", out)
  end

  def test_call_help
    out, _err = capture_io do
      exception = assert_raises(SystemExit) { VimPK::CLI.new(["--help"]).call }
      assert_equal(0, exception.status)
    end

    assert_match(/Usage:/, out)
  end

  def test_call_list
    using_pack_path do |path|
      out, _err = capture_io do
        exception = assert_raises(SystemExit) { VimPK::CLI.new(["list", "--path", path]).call }
        assert_equal(0, exception.status)
      end

      assert_equal(<<~LIST, out)
        #{path}/colors/opt/pretty
        #{path}/plugins/start/someplug
      LIST
    end
  end
end
