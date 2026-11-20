# frozen_string_literal: true

# Builds benchmark/HISTORY.md from the versions of benchmark/results.json in
# the git history, with charts that GitHub renders (Mermaid).
#
#   bundle exec rake benchmark:history
#
# `rake benchmark` also updates HISTORY.md, including the results it just
# wrote, so that they can be committed together.

require "json"

module CurlybarsBenchmark
  class History
    RESULTS = "benchmark/results.json"
    FORMAT = 1
    TEMPLATES = %w[small medium large].freeze

    STEP_NAMES = {
      "lex" => "Lex",
      "parse" => "Parse",
      "compile" => "Compile",
      "eval" => "Eval",
      "render" => "Render",
      "render_with_action_view" => "Render with ActionView"
    }.freeze

    # A line color per charted step, the same in every chart. They're from
    # the Okabe-Ito palette, which is designed to stay distinguishable with
    # color blindness, leaving out its yellow and black, which are hard to see
    # on white and dark backgrounds.
    STEP_COLORS = {
      "lex" => "#0072B2", # blue
      "parse" => "#E69F00", # orange
      "compile" => "#009E73", # bluish green
      "eval" => "#CC79A7", # reddish purple
      "render" => "#D55E00" # vermillion
    }.freeze

    # The steps in each chart. All steps are in the tables. Rendering takes
    # orders of magnitude more time and allocations than the other steps,
    # which would be flat lines at the bottom of a chart that also shows it.
    # Render with ActionView isn't charted: it adds a small, nearly constant
    # overhead to Render, so its line would cover Render's.
    CHARTS = {
      "Lex, Parse, Compile and Eval" => %w[lex parse compile eval],
      "Render" => %w[render]
    }.freeze

    Run = Struct.new(:label, :data) do
      def machine_key
        [data.dig("machine", "cpu"), data.dig("machine", "os").to_s.split.values_at(0, -1), data.dig("versions", "ruby"), data.dig("versions", "yjit")]
      end

      def machine_name
        cpu, (os, architecture), ruby, yjit = machine_key
        "#{cpu}, #{os} #{architecture}, Ruby #{ruby}, YJIT #{yjit ? 'enabled' : 'disabled'}"
      end

      def step(template, step)
        data.dig("templates", template, "steps", step)
      end
    end

    def initialize(root: File.dirname(__dir__))
      @root = root
    end

    def write
      path = File.join(@root, "benchmark", "HISTORY.md")
      File.write(path, to_markdown)
      puts "Wrote #{path}"
    end

    def to_markdown
      runs = self.runs
      [header, runs_table(runs), allocations(runs), times(runs)].join("\n")
    end

    # The committed versions of results.json, oldest first, followed by the
    # one in the working tree if it hasn't been committed yet.
    def runs
      contents = git("log", "--first-parent", "--reverse", "--format=%H", "--", RESULTS).split.map do |sha|
        git("show", "#{sha}:#{RESULTS}")
      end

      path = File.join(@root, RESULTS)
      if File.exist?(path)
        current = File.read(path)
        contents << current unless current == git("show", "HEAD:#{RESULTS}")
      end

      results = contents.filter_map { |content| parse(content) }
      labels = Hash.new(0)
      results.map do |data|
        label = "#{data['ref'] || data['commit'] || 'unknown'}#{'*' if data['uncommitted_changes']}"
        labels[label] += 1
        Run.new(labels[label] > 1 ? "#{label} (#{labels[label]})" : label, data)
      end
    end

    private

    def parse(content)
      data = JSON.parse(content)
      data if data["format"] == FORMAT
    rescue JSON::ParserError
      nil
    end

    def git(*args)
      IO.popen(["git", "-C", @root, *args], err: File::NULL, &:read)
    rescue SystemCallError
      ""
    end

    def header
      <<~MARKDOWN
        # Benchmark history

        Generated from the versions of `benchmark/results.json` in the git history (following only the first parent of merges) by `bundle exec rake benchmark` or `bundle exec rake benchmark:history`. Don't edit this file by hand. The latest results, and what each step measures, are in [RESULTS.md](RESULTS.md).

        Each run is labeled with the commit it measured, or the git ref (e.g. a release tag) for runs of earlier versions. `*` marks runs with uncommitted changes.
      MARKDOWN
    end

    def runs_table(runs)
      rows = runs.map do |run|
        versions = run.data["versions"]
        cells = [
          run.label,
          run.data["generated_at"].to_s[0, 10],
          versions["curlybars"],
          versions["ruby"],
          versions["yjit"] ? "enabled" : "disabled",
          versions["actionview"],
          "#{run.data.dig('machine', 'cpu')}, #{run.data.dig('machine', 'os')}"
        ]
        "| #{cells.map { |cell| escape(cell) }.join(' | ')} |"
      end

      <<~MARKDOWN
        ## Runs

        | Run | Date | Curlybars | Ruby | YJIT | ActionView | Machine |
        |---|---|---|---|---|---|---|
        #{rows.join("\n")}
      MARKDOWN
    end

    def allocations(runs)
      sections = TEMPLATES.map do |template|
        charts = CHARTS.map do |name, steps|
          chart("#{template}: allocations during #{name}", "Objects", runs, steps) do |run, step|
            run.step(template, step)&.fetch("allocations")
          end
        end
        table = table(runs, template) { |result| delimit(result["allocations"]) }

        "### #{template}\n\n#{charts.join("\n")}\n#{table}"
      end

      <<~MARKDOWN
        ## Allocations per call

        Allocations don't depend on the machine, but can change with the Ruby and Rails versions (see "Runs").

        #{sections.join("\n")}
      MARKDOWN
    end

    def times(runs)
      sections = runs.group_by(&:machine_key).map do |_, machine_runs|
        templates = TEMPLATES.map do |template|
          charts = CHARTS.map do |name, steps|
            chart("#{template}: time during #{name}", "ms", machine_runs, steps) do |run, step|
              seconds = run.step(template, step)&.fetch("seconds_per_call")
              seconds && (seconds * 1000).round(3)
            end
          end
          table = table(machine_runs, template) { |result| duration(result["seconds_per_call"]) }

          "#### #{template}\n\n#{charts.join("\n")}\n#{table}"
        end

        "### #{machine_runs.first.machine_name}\n\n#{templates.join("\n")}"
      end

      <<~MARKDOWN
        ## Time per call

        Times are only comparable between runs on the same machine, Ruby version and YJIT setting, so they are grouped by those.

        #{sections.join("\n")}
      MARKDOWN
    end

    # A Mermaid line chart with a named line (shown in the legend) per step
    # and a point per run. A line needs a value for every run, so runs
    # without a value for any of the steps (e.g. versions that can't render
    # the template) are left out, and so are steps that some of the
    # remaining runs don't have a value for (e.g. a step that didn't exist
    # yet).
    def chart(title, unit, runs, steps)
      values = runs.to_h { |run| [run, steps.to_h { |step| [step, yield(run, step)] }] }
      runs = runs.select { |run| values[run].values.any? }
      steps = steps.select { |step| runs.all? { |run| values[run][step] } }
      return "" if runs.empty? || steps.empty?

      lines = steps.map do |step|
        %(  line "#{STEP_NAMES.fetch(step)}" [#{runs.map { |run| values[run][step] }.join(', ')}])
      end
      maximum = steps.flat_map { |step| runs.map { |run| values[run][step] } }.max
      # Mermaid colors the lines in order from plotColorPalette.
      <<~MARKDOWN
        ```mermaid
        ---
        config:
          themeVariables:
            xyChart:
              plotColorPalette: "#{steps.map { |step| STEP_COLORS.fetch(step) }.join(', ')}"
        ---
        xychart-beta
          title "#{title}"
          x-axis [#{runs.map { |run| run.label.inspect }.join(', ')}]
          y-axis "#{unit}" 0 --> #{axis_maximum(maximum)}
        #{lines.join("\n")}
        ```
      MARKDOWN
    end

    # A row per run that measured the template (e.g. not for versions that
    # can't render it), with a column per step that any of them measured.
    def table(runs, template)
      runs = runs.select { |run| run.data.dig("templates", template) }
      steps = STEP_NAMES.keys.select { |step| runs.any? { |run| run.step(template, step) } }
      rows = runs.map do |run|
        cells = steps.map do |step|
          result = run.step(template, step)
          result ? yield(result) : ""
        end
        "| #{run.label} | #{cells.join(' | ')} |"
      end

      <<~MARKDOWN
        | Run | #{steps.map { |step| STEP_NAMES.fetch(step) }.join(' | ')} |
        |---|#{'--:|' * steps.size}
        #{rows.join("\n")}
      MARKDOWN
    end

    # Starting the y-axis at 0 keeps small changes from looking big. Leave
    # some room above the highest point.
    def axis_maximum(maximum)
      return 1 unless maximum.positive?

      exponent = Math.log10(maximum * 1.1).floor - 1
      rounded = ((maximum * 1.1) / (10.0**exponent)).ceil * (10.0**exponent)
      exponent.negative? ? rounded.round(-exponent) : rounded.round
    end

    def duration(seconds)
      if seconds >= 1e-3
        "%.2f ms" % (seconds * 1e3)
      else
        "%.1f µs" % (seconds * 1e6)
      end
    end

    def delimit(number)
      number.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
    end

    def escape(value)
      value.to_s.tr("|", "¦")
    end
  end
end

CurlybarsBenchmark::History.new.write if $PROGRAM_NAME == __FILE__
