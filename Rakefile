# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# release-please creates the tag and the release commit.
Rake::Task["release:source_control_push"].clear

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test
