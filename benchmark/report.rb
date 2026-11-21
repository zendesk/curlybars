# frozen_string_literal: true

# Benchmarks each step of turning the templates in benchmark/templates/ into
# HTML. Writes the results to benchmark/RESULTS.md, and in a machine-readable
# form to benchmark/results.json, and updates benchmark/HISTORY.md from the
# versions of results.json in the git history (see benchmark/history.rb).
#
#   bundle exec rake benchmark
#
# BENCHMARK_WARMUP and BENCHMARK_TIME set the warmup and measuring time of
# each measurement in seconds (default 2 and 5). Use smaller values to try
# out changes to the benchmark itself, not to produce results.
#
# To benchmark an earlier version of Curlybars with this benchmark, use
# `rake benchmark:ref[v1.16.1]` (see benchmark/ref.rb), which sets
# BENCHMARK_REF to the git ref whose lib/ is loaded.

require "bundler/setup"
require "benchmark/ips"
require "etc"
require "json"
require "active_support/all"
require "action_view"
require "curlybars"
require "curlybars/template_handler"
require_relative "support"
require_relative "history"

module CurlybarsBenchmark
  class Report
    TEMPLATES = %w[small medium large].freeze

    # `key` identifies the step in results.json, so it must not change.
    Step = Struct.new(:key, :name, :description)

    STEPS = [
      Step.new("lex",     "Lex",     "`Curlybars::Lexer.lex`: source to tokens."),
      Step.new("parse",   "Parse",   "`Curlybars::Parser.parse`: tokens to syntax tree."),
      Step.new("compile", "Compile", "`Node::Root#compile`: syntax tree to Ruby code."),
      Step.new("eval",    "Eval",    "`Kernel#eval`: Ruby code to a lambda. Ruby parses the generated code; ActionView does this once per template."),
      Step.new("render",  "Render",  "Calling the lambda: renders the template, including its partials."),
      Step.new("render_with_action_view", "Render with ActionView", "`ActionView::Base#render` of the template through `Curlybars::TemplateHandler`, including setting up the presenter.")
    ].freeze

    # The files written by the benchmark, which don't count as uncommitted
    # changes to the code being measured.
    OUTPUT_FILES = %w[RESULTS.md results.json HISTORY.md].freeze

    # `steps` is nil for templates that the measured version can't render.
    TemplateResult = Struct.new(:name, :source, :code, :output, :steps) do
      def skipped?
        steps.nil?
      end
    end
    StepResult = Struct.new(:ips, :error, :allocations)

    def initialize(warmup:, time:, ref: nil, directory: __dir__)
      @warmup = warmup
      @time = time
      @ref = ref
      @directory = directory
    end

    attr_reader :ref

    def run
      configure

      templates = TEMPLATES.map { |name| measure(name) }
      write("RESULTS.md", Markdown.new(templates, environment, warmup: @warmup, time: @time).to_s)
      write("results.json", "#{JSON.pretty_generate(Json.new(templates, self).to_h)}\n")
      write("HISTORY.md", History.new.to_markdown)
    end

    # The commit of the Curlybars code being measured.
    def commit_sha
      @commit_sha ||= ref ? short_sha("#{ref}^{commit}") : benchmark_commit_sha
    end

    # The commit of the benchmark itself. The same as `commit_sha`, unless
    # `ref` is given.
    def benchmark_commit_sha
      @benchmark_commit_sha ||= short_sha("HEAD")
    end

    # Whether the measured code has uncommitted changes. With `ref`, the
    # code comes from git, so only changes to the benchmark count.
    def uncommitted_changes?
      exclude = OUTPUT_FILES.map { |file| ":!benchmark/#{file}" }
      paths = ref ? %w[benchmark] : %w[lib benchmark]
      git("status", "--porcelain", "--", *paths, *exclude).present?
    end

    def settings
      { "warmup_seconds" => @warmup, "time_seconds" => @time }
    end

    def versions
      {
        "curlybars" => Curlybars::VERSION,
        "ruby" => RUBY_VERSION,
        "ruby_description" => RUBY_DESCRIPTION,
        "yjit" => yjit?,
        "actionview" => ActionView.version.to_s,
        "activesupport" => ActiveSupport.version.to_s,
        "benchmark_ips" => Benchmark::IPS::VERSION
      }
    end

    def machine
      {
        "os" => Etc.uname.values_at(:sysname, :release, :machine).join(" "),
        "cpu" => cpu,
        "cores" => Etc.nprocessors,
        "memory_gb" => memory_gb
      }
    end

    private

    def write(file, content)
      path = File.join(@directory, file)
      File.write(path, content)
      puts "Wrote #{path}"
    end

    def git(*args)
      IO.popen(["git", "-C", File.dirname(__dir__), *args], err: File::NULL, &:read)
    rescue SystemCallError
      ""
    end

    def short_sha(revision)
      git("rev-parse", "--short", revision).strip.presence
    end

    # Partial providers were added in Curlybars 1.16.0. Before that,
    # `{{> name}}` called a presenter method.
    def partial_providers?
      Curlybars::Configuration.method_defined?(:partial_provider_class)
    end

    # Curlybars before 1.17.0 processed `{{~` and `~}}` between lexing and
    # parsing, which is part of the Lex step here.
    def lex(source, identifier)
      tokens = Curlybars::Lexer.lex(source, identifier)
      Curlybars::Processor::Tilde.process!(tokens, identifier) if defined?(Curlybars::Processor::Tilde)
      tokens
    end

    def configure
      ActionView::Template.register_template_handler(:hbs, Curlybars::TemplateHandler)

      Curlybars.configure do |config|
        config.presenters_namespace = "curlybars_benchmark"
        config.global_helpers_provider_classes = [GlobalHelpers]
        config.partial_provider_class = Partials if partial_providers?
      end

      view_class = ActionView::Base.with_empty_template_cache
      @view = view_class.new(ActionView::LookupContext.new([__dir__]), {}, nil)
    end

    def measure(name)
      source = File.read(File.join(__dir__, "templates", "#{name}.html.hbs"))
      if source.include?("{{>") && !partial_providers?
        $stdout.puts "#{name}: skipped, because Curlybars #{Curlybars::VERSION} has no partial providers"
        return TemplateResult.new(name, source, nil, nil, nil)
      end

      identifier = "templates/#{name}"
      presenter = Templates.const_get("#{name.capitalize}Presenter").new(nil)
      helpers = [GlobalHelpers.new]
      partials = Partials.new

      tokens = lex(source, identifier)
      tree = Curlybars::Parser.parse(tokens)
      code = tree.compile
      lambda_code = "lambda { |presenter, global_helpers_providers, partial_provider| #{code} }"
      template = CleanBinding.eval(lambda_code)

      output = template.call(presenter, helpers, partials).to_s
      rails_output = @view.render(template: identifier).to_s
      raise "ActionView rendered #{name} differently" unless output == rails_output

      steps = {
        "lex" => -> { lex(source, identifier) },
        "parse" => -> { Curlybars::Parser.parse(tokens) },
        "compile" => -> { tree.compile },
        "eval" => -> { CleanBinding.eval(lambda_code) },
        "render" => -> { template.call(presenter, helpers, partials) },
        "render_with_action_view" => -> { @view.render(template: identifier) }
      }

      results = steps.to_h do |step, block|
        $stdout.puts "#{name}: #{step}"
        [step, measure_step(step, block)]
      end

      TemplateResult.new(name, source, code, output, results)
    end

    def measure_step(step, block)
      GC.start
      report = Benchmark.ips(quiet: true) do |x|
        x.config(warmup: @warmup, time: @time)
        x.report(step, &block)
      end
      entry = report.entries.first

      StepResult.new(entry.stats.central_tendency, entry.stats.error_percentage, allocations(block))
    end

    # Allocated objects per call. Measured separately from the time, over a
    # few calls after a warmup call.
    def allocations(block, calls: 5)
      block.call
      before = GC.stat(:total_allocated_objects)
      calls.times { block.call }
      (GC.stat(:total_allocated_objects) - before) / calls
    end

    def environment
      commit = commit_sha || "unknown"
      commit = "#{ref} (#{commit})" if ref
      commit = "#{commit} (with uncommitted changes)" if uncommitted_changes?

      environment = {
        "Date" => Time.now.utc.strftime("%Y-%m-%d"),
        "Commit" => commit,
        "Curlybars" => Curlybars::VERSION,
        "Ruby" => RUBY_DESCRIPTION,
        "YJIT" => yjit? ? "enabled" : "disabled",
        "ActionView" => ActionView.version.to_s,
        "ActiveSupport" => ActiveSupport.version.to_s,
        "benchmark-ips" => Benchmark::IPS::VERSION,
        "OS" => machine["os"],
        "CPU" => "#{machine['cpu']} (#{machine['cores']} cores)",
        "Memory" => memory_gb ? "#{memory_gb} GB" : "unknown"
      }
      environment["Benchmark commit"] = benchmark_commit_sha || "unknown" if ref
      environment
    end

    def yjit?
      defined?(RubyVM::YJIT) ? RubyVM::YJIT.enabled? : false
    end

    def cpu
      case Etc.uname[:sysname]
      when "Darwin"
        `sysctl -n machdep.cpu.brand_string 2>/dev/null`.strip
      when "Linux"
        line = File.foreach("/proc/cpuinfo").find { |info| info.start_with?("model name") }
        line.to_s.split(":", 2).last.to_s.strip
      end.then { |name| name.nil? || name.empty? ? "unknown CPU" : name }
    end

    def memory_gb
      bytes = case Etc.uname[:sysname]
      when "Darwin"
        `sysctl -n hw.memsize 2>/dev/null`.to_i
      when "Linux"
        File.foreach("/proc/meminfo").find { |line| line.start_with?("MemTotal:") }.to_s[/\d+/].to_i * 1024
      else
        0
      end
      (bytes / (1024.0**3)).round if bytes.positive?
    end

    # Evaluates code in a binding without local variables, like a template
    # compiled by ActionView.
    module CleanBinding
      def self.eval(code)
        # rubocop:disable Security/Eval -- the benchmark measures eval
        Kernel.eval(code, empty_binding, "(benchmark)")
        # rubocop:enable Security/Eval
      end

      def self.empty_binding
        binding
      end
    end

    # The contents of results.json. benchmark/history.rb reads every version
    # of it from the git history, so keep the format backwards compatible:
    # add keys rather than renaming or removing them, and increase "format"
    # if that's not possible.
    class Json
      FORMAT = 1

      def initialize(templates, report)
        @templates = templates
        @report = report
      end

      def to_h
        {
          "format" => FORMAT,
          "generated_at" => Time.now.utc.iso8601,
          "ref" => @report.ref,
          "commit" => @report.commit_sha,
          "benchmark_commit" => @report.benchmark_commit_sha,
          "uncommitted_changes" => @report.uncommitted_changes?,
          "versions" => @report.versions,
          "machine" => @report.machine,
          "settings" => @report.settings,
          "templates" => @templates.reject(&:skipped?).to_h { |template| [template.name, template_to_h(template)] },
          "skipped_templates" => @templates.select(&:skipped?).map(&:name)
        }
      end

      private

      def template_to_h(template)
        {
          "source_bytes" => template.source.bytesize,
          "generated_ruby_bytes" => template.code.bytesize,
          "output_bytes" => template.output.bytesize,
          "steps" => STEPS.to_h do |step|
            result = template.steps.fetch(step.key)
            [step.key, {
              "seconds_per_call" => significant(1.0 / result.ips),
              "error_percent" => result.error.round(1),
              "allocations" => result.allocations
            }]
          end
        }
      end

      # Four significant digits are more than the measurements' precision,
      # and keep the diffs of results.json readable.
      def significant(number)
        Float("%.4g" % number)
      end
    end

    class Markdown
      def initialize(templates, environment, warmup:, time:)
        @templates = templates
        @environment = environment
        @warmup = warmup
        @time = time
      end

      def to_s
        [header, environment, templates, times, allocations, steps].join("\n")
      end

      private

      def header
        <<~MARKDOWN
          # Benchmark results

          Generated by `bundle exec rake benchmark` (see `benchmark/report.rb`). Don't edit this file by hand.

          Each step is measured with benchmark-ips for #{@time} seconds, after a warmup of #{@warmup} seconds. Allocations are objects allocated per call.
        MARKDOWN
      end

      def environment
        rows = @environment.map { |key, value| "| #{key} | #{escape(value)} |" }
        <<~MARKDOWN
          ## Environment

          |   |   |
          |---|---|
          #{rows.join("\n")}
        MARKDOWN
      end

      def templates
        rows = @templates.map do |template|
          if template.skipped?
            "| #{template.name} | #{size(template.source)} | not supported by this version | |"
          else
            "| #{template.name} | #{size(template.source)} | #{size(template.code)} | #{size(template.output)} |"
          end
        end
        <<~MARKDOWN
          ## Templates

          The templates are in `benchmark/templates`, the partials in `benchmark/partials`.

          | Template | Source | Generated Ruby | Output |
          |----------|-------:|---------------:|-------:|
          #{rows.join("\n")}
        MARKDOWN
      end

      def times
        table("Time per call") do |result|
          "#{duration(1.0 / result.ips)} ± #{'%.1f' % result.error}%"
        end
      end

      def allocations
        table("Allocations per call") { |result| delimit(result.allocations) }
      end

      def steps
        rows = STEPS.map { |step| "| #{step.name} | #{step.description} |" }
        <<~MARKDOWN
          ## Steps

          | Step | What is measured |
          |------|------------------|
          #{rows.join("\n")}
        MARKDOWN
      end

      def table(title)
        heading = @templates.map(&:name)
        rows = STEPS.map do |step|
          cells = @templates.map { |template| template.skipped? ? "–" : yield(template.steps.fetch(step.key)) }
          "| #{step.name} | #{cells.join(' | ')} |"
        end
        <<~MARKDOWN
          ## #{title}

          | Step | #{heading.join(' | ')} |
          |------|#{'--:|' * heading.size}
          #{rows.join("\n")}
        MARKDOWN
      end

      def duration(seconds)
        if seconds >= 1e-3
          "%.2f ms" % (seconds * 1e3)
        else
          "%.1f µs" % (seconds * 1e6)
        end
      end

      def size(string)
        "#{delimit(string.bytesize)} B, #{delimit(string.lines.count)} lines"
      end

      def delimit(number)
        number.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
      end

      def escape(value)
        value.to_s.tr("|", "¦")
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  CurlybarsBenchmark::Report.new(
    warmup: Float(ENV.fetch("BENCHMARK_WARMUP", 2)),
    time: Float(ENV.fetch("BENCHMARK_TIME", 5)),
    ref: ENV["BENCHMARK_REF"].presence
  ).run
end
