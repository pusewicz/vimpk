# frozen_string_literal: true

require_relative "lib/vimpk/version"

Gem::Specification.new do |spec|
  spec.name = "vimpk"
  spec.version = VimPK::VERSION
  spec.authors = ["Piotr Usewicz"]
  spec.email = ["piotr@layer22.com"]

  spec.summary = "VimPK is a tool for managing Vim plugins via packages."
  spec.homepage = "https://github.com/pusewicz/vimpk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "blob/main/CHANGELOG.md")
  spec.metadata["github_repo"] = "ssh://github.com/pusewicz/vimpk"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile .standard.yml CHANGELOG.md CODE_OF_CONDUCT.md])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
