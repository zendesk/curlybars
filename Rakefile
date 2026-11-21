# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'

task default: [:spec, :rubocop]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Run the benchmarks and write benchmark/RESULTS.md, results.json and HISTORY.md'
task :benchmark do
  ruby 'benchmark/report.rb'
end

namespace :benchmark do
  desc 'Run the benchmarks against the lib/ of a git ref, e.g. benchmark:ref[v1.16.1]'
  task :ref, [:ref] do |_, args|
    ruby 'benchmark/ref.rb', args.fetch(:ref)
  end

  desc 'Write benchmark/HISTORY.md from the versions of benchmark/results.json in git'
  task :history do
    ruby 'benchmark/history.rb'
  end
end

require 'rubocop/rake_task'
desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop)
