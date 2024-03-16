# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = true
  t.test_globs = ["test/**/test_*.rb"]
end

if RUBY_VERSION >= "2.7"
  require "standard/rake"
  task default: %i[test standard]
else
  task default: %i[test]
end
