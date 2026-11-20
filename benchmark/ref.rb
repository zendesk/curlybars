# frozen_string_literal: true

# Runs the current benchmark against an earlier version of Curlybars, e.g. a
# release tag:
#
#   bundle exec rake 'benchmark:ref[v1.16.1]'
#
# Extracts lib/ and curlybars.gemspec of the ref into a temporary directory,
# installs that version's dependencies, and runs benchmark/report.rb with
# that lib/ and BENCHMARK_REF set. Its dependencies start from the current
# Gemfile.lock, so the ones shared with the current version (Rails, etc.)
# keep their versions.

require "bundler"
require "fileutils"
require "shellwords"
require "tmpdir"

ref = ARGV.fetch(0) { abort "Usage: ruby benchmark/ref.rb <git ref>" }
root = File.dirname(__dir__)

commit = ->(name) { system("git", "-C", root, "rev-parse", "--verify", "--quiet", "#{name}^{commit}", out: File::NULL) }
unless commit.call(ref)
  suggestion = " (did you mean v#{ref}?)" if commit.call("v#{ref}")
  abort "Unknown git ref #{ref}#{suggestion}"
end

Dir.mktmpdir("curlybars-benchmark-") do |dir|
  archive = "git -C #{root.shellescape} archive #{ref.shellescape} lib curlybars.gemspec"
  system("#{archive} | tar -x -C #{dir.shellescape}", exception: true)

  gemfile = File.join(dir, "Gemfile")
  File.write(gemfile, <<~RUBY)
    source "https://rubygems.org"

    gemspec
    gem "benchmark-ips"
  RUBY
  FileUtils.cp(File.join(root, "Gemfile.lock"), File.join(dir, "Gemfile.lock"))

  env = { "BUNDLE_GEMFILE" => gemfile, "BENCHMARK_REF" => ref }
  Bundler.with_unbundled_env do
    system(env, "bundle", "install", "--quiet", exception: true)
    system(env, "bundle", "exec", "ruby", File.join(__dir__, "report.rb"), chdir: root, exception: true)
  end
end
