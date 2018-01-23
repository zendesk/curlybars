require 'bundler/setup'
require 'bundler/gem_tasks'

task default: [:spec, :rubocop]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop)
