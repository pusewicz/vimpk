# frozen_string_literal: true

require "test_helper"
require "json"

class TestManifest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @manifest = VimPK::Manifest.new(@tmpdir)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_initialize_creates_empty_manifest
    assert_empty @manifest.all
    assert @manifest.empty?
    assert_equal 0, @manifest.size
  end

  def test_add_and_get
    @manifest.add("ale", {
      remote_url: "https://github.com/dense-analysis/ale.git",
      branch: "master",
      commit: "abc123",
      pack: "plugins",
      type: "start"
    })

    assert @manifest.exists?("ale")
    assert_equal 1, @manifest.size

    entry = @manifest.get("ale")
    assert_equal "https://github.com/dense-analysis/ale.git", entry["remote_url"]
    assert_equal "master", entry["branch"]
    assert_equal "abc123", entry["commit"]
    assert_equal "plugins", entry["pack"]
    assert_equal "start", entry["type"]
  end

  def test_remove
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})
    assert @manifest.exists?("ale")

    @manifest.remove("ale")
    refute @manifest.exists?("ale")
    assert @manifest.empty?
  end

  def test_update
    @manifest.add("ale", {
      remote_url: "https://github.com/dense-analysis/ale.git",
      commit: "abc123",
      pack: "plugins"
    })

    @manifest.update("ale", {commit: "def456", pack: "linting"})

    entry = @manifest.get("ale")
    assert_equal "def456", entry["commit"]
    assert_equal "linting", entry["pack"]
    assert_equal "https://github.com/dense-analysis/ale.git", entry["remote_url"]
  end

  def test_update_nonexistent_does_nothing
    @manifest.update("nonexistent", {commit: "abc123"})
    refute @manifest.exists?("nonexistent")
  end

  def test_save_and_load
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})
    @manifest.add("vim-fugitive", {remote_url: "https://github.com/tpope/vim-fugitive.git"})
    @manifest.save

    # Create a new manifest instance to test loading
    loaded = VimPK::Manifest.new(@tmpdir)
    assert loaded.exists?("ale")
    assert loaded.exists?("vim-fugitive")
    assert_equal 2, loaded.size
  end

  def test_save_sorts_alphabetically
    @manifest.add("vim-fugitive", {remote_url: "https://github.com/tpope/vim-fugitive.git"})
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})
    @manifest.add("nerdtree", {remote_url: "https://github.com/preservim/nerdtree.git"})
    @manifest.save

    content = File.read(File.join(@tmpdir, "manifest.json"))
    data = JSON.parse(content)

    assert_equal %w[ale nerdtree vim-fugitive], data.keys
  end

  def test_find_by_remote
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})
    @manifest.add("vim-fugitive", {remote_url: "https://github.com/tpope/vim-fugitive.git"})

    result = @manifest.find_by_remote("https://github.com/dense-analysis/ale.git")
    assert_equal "ale", result[0]
    assert_equal "https://github.com/dense-analysis/ale.git", result[1]["remote_url"]
  end

  def test_find_by_remote_normalizes_urls
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})

    # Should find without .git suffix
    result = @manifest.find_by_remote("https://github.com/dense-analysis/ale")
    assert_equal "ale", result[0]

    # Should find with git@ format
    result = @manifest.find_by_remote("git@github.com:dense-analysis/ale.git")
    assert_equal "ale", result[0]

    # Should find case-insensitively
    result = @manifest.find_by_remote("https://github.com/Dense-Analysis/ALE.git")
    assert_equal "ale", result[0]
  end

  def test_find_by_remote_returns_nil_when_not_found
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})

    result = @manifest.find_by_remote("https://github.com/tpope/vim-fugitive.git")
    assert_nil result
  end

  def test_each
    @manifest.add("ale", {remote_url: "https://github.com/dense-analysis/ale.git"})
    @manifest.add("vim-fugitive", {remote_url: "https://github.com/tpope/vim-fugitive.git"})

    names = []
    @manifest.each { |name, _data| names << name }

    assert_includes names, "ale"
    assert_includes names, "vim-fugitive"
  end

  def test_handles_corrupt_json
    File.write(File.join(@tmpdir, "manifest.json"), "not valid json")
    manifest = VimPK::Manifest.new(@tmpdir)
    assert_empty manifest.all
  end

  def test_handles_missing_file
    manifest = VimPK::Manifest.new(@tmpdir)
    assert_empty manifest.all
  end
end
