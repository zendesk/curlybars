require 'bundler/setup'
require 'private_gem/tasks'
require 'wwtd/tasks'

task default: [:spec, :rubocop]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w(Rakefile lib/**/*.rb spec/**/*.rb)
  task.formatters = %w(progress)
  task.fail_on_error = true
end
