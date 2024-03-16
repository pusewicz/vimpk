# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  def test_valid_command
    assert_equal :install_command, VimPK::CLI.new(["i"]).command
    assert_equal :install_command, VimPK::CLI.new(["install"]).command
    assert_equal :move_command, VimPK::CLI.new(["mv"]).command
    assert_equal :move_command, VimPK::CLI.new(["move"]).command
    assert_equal :update_command, VimPK::CLI.new(["u"]).command
    assert_equal :update_command, VimPK::CLI.new(["update"]).command
    assert_equal :remove_command, VimPK::CLI.new(["rm"]).command
    assert_equal :remove_command, VimPK::CLI.new(["remove"]).command
  end

  def test_invalid_command
    out, _err = capture_io do
      VimPK::CLI.new(["foo"])
    end

    assert_equal(/Unknown command: foo/, out)
  end
end
