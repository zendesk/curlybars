require 'tempfile'

load File.expand_path('../../bin/curlybars-indent-lint', __dir__)

describe "curlybars-indent-lint" do
  def lint(source, indent_size: 2)
    file = Tempfile.new(['test', '.hbs'])
    file.write(source)
    file.close
    lint_file(file.path, indent_size)
  ensure
    file&.unlink
  end

  describe "#classify_line" do
    it "classifies a block opening tag" do
      expect(classify_line("{{#if visible}}")).to eq(:open)
    end

    it "classifies a block opening tag with tilde" do
      expect(classify_line("{{~#if visible}}")).to eq(:open)
    end

    it "classifies a block closing tag" do
      expect(classify_line("{{/if}}")).to eq(:close)
    end

    it "classifies a block closing tag with tilde" do
      expect(classify_line("{{~/if~}}")).to eq(:close)
    end

    it "classifies an else tag" do
      expect(classify_line("{{else}}")).to eq(:else)
    end

    it "classifies an else tag with tilde" do
      expect(classify_line("{{~else~}}")).to eq(:else)
    end

    it "classifies plain text" do
      expect(classify_line("<p>hello</p>")).to eq(:plain)
    end

    it "classifies a simple output tag as plain" do
      expect(classify_line("{{title}}")).to eq(:plain)
    end

    it "classifies an inline block (open + close on same line) as plain" do
      expect(classify_line("{{#if x}}yes{{/if}}")).to eq(:plain)
    end

    it "classifies an each opening tag" do
      expect(classify_line("{{#each items}}")).to eq(:open)
    end

    it "classifies a with opening tag" do
      expect(classify_line("{{#with author}}")).to eq(:open)
    end

    it "classifies an unless opening tag" do
      expect(classify_line("{{#unless hidden}}")).to eq(:open)
    end

    it "classifies a custom block helper opening tag" do
      expect(classify_line('{{#markdown_to_html}}')).to eq(:open)
    end
  end

  describe "#lint_file" do
    context "with correctly indented templates" do
      it "passes a simple if/else/end block" do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
          {{else}}
            <p>goodbye</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes nested blocks" do
        warnings = lint(<<~HBS)
          {{#each users}}
            {{#if active}}
              <span>{{name}}</span>
            {{else}}
              <span>inactive</span>
            {{/if}}
          {{/each}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes blocks nested inside HTML" do
        warnings = lint(<<~HBS)
          <div>
            <ul>
              {{#each items}}
                <li>{{name}}</li>
              {{/each}}
            </ul>
          </div>
        HBS

        expect(warnings).to be_empty
      end

      it "passes an inline block on a single line" do
        warnings = lint(<<~HBS)
          <p>{{#if show}}yes{{/if}}</p>
        HBS

        expect(warnings).to be_empty
      end

      it "passes a template with no blocks at all" do
        warnings = lint(<<~HBS)
          <div>
            <p>{{title}}</p>
              <span>anything</span>
          </div>
        HBS

        expect(warnings).to be_empty
      end

      it "ignores blank lines" do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>

            <p>world</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes with tilde whitespace control syntax" do
        warnings = lint(<<~HBS)
          {{~#if visible~}}
            <p>hello</p>
          {{~else~}}
            <p>goodbye</p>
          {{~/if~}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes a with block" do
        warnings = lint(<<~HBS)
          {{#with author}}
            <span>{{name}}</span>
          {{/with}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes an unless block" do
        warnings = lint(<<~HBS)
          {{#unless hidden}}
            <p>visible</p>
          {{/unless}}
        HBS

        expect(warnings).to be_empty
      end
    end

    context "with incorrectly indented templates" do
      it "allows content at the same level as a block opener" do
        warnings = lint(<<~HBS)
          {{#if visible}}
          <p>hello</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "reports content less indented than a block opener", :aggregate_failures do
        warnings = lint(<<~HBS)
            {{#if visible}}
          <p>hello</p>
            {{/if}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(2)
        expect(warnings.first.message).to include("inside block")
      end

      it "reports a closing tag not aligned with its opener", :aggregate_failures do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
              {{/if}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(3)
        expect(warnings.first.message).to include("to match opening tag")
      end

      it "reports an else tag not aligned with its opener", :aggregate_failures do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
              {{else}}
            <p>goodbye</p>
          {{/if}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(3)
        expect(warnings.first.message).to include("to match opening tag")
      end

      it "allows content over-indented inside a block (e.g. HTML nesting)" do
        warnings = lint(<<~HBS)
          {{#if visible}}
              <p>hello</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "reports multiple issues in one file", :aggregate_failures do
        warnings = lint(<<~HBS)
            {{#if visible}}
          <p>hello</p>
              {{else}}
                  <p>goodbye</p>
            {{/if}}
        HBS

        expect(warnings.length).to eq(2)
        expect(warnings.map(&:line)).to eq([2, 3])
      end

      it "allows content at same level as nested block opener" do
        warnings = lint(<<~HBS)
          {{#each users}}
            {{#if active}}
            <span>{{name}}</span>
            {{/if}}
          {{/each}}
        HBS

        expect(warnings).to be_empty
      end

      it "reports content less indented than nested block opener", :aggregate_failures do
        warnings = lint(<<~HBS)
          {{#each users}}
            {{#if active}}
          <span>{{name}}</span>
            {{/if}}
          {{/each}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(3)
      end
    end

    context "with structural errors" do
      it "reports an unexpected closing tag with no opener", :aggregate_failures do
        warnings = lint(<<~HBS)
          <p>hello</p>
          {{/if}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(2)
        expect(warnings.first.message).to include("no matching opener")
      end

      it "reports an unexpected else with no opener", :aggregate_failures do
        warnings = lint(<<~HBS)
          <p>hello</p>
          {{else}}
          <p>goodbye</p>
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(2)
        expect(warnings.first.message).to include("no matching opener")
      end

      it "reports an unclosed block", :aggregate_failures do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to be_nil
        expect(warnings.first.message).to include("unclosed block")
      end
    end

    context "with custom indent size" do
      it "passes a 4-space indented template with indent_size 4" do
        warnings = lint(<<~HBS, indent_size: 4)
          {{#if visible}}
              <p>hello</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "allows content indented less than indent_size but not less than opener" do
        warnings = lint(<<~HBS, indent_size: 4)
          {{#if visible}}
            <p>hello</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "passes a template with indent_size 1" do
        warnings = lint(<<~HBS, indent_size: 1)
          {{#if visible}}
           <p>hello</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end
    end

    context "with else branches" do
      it "resets content indentation after else" do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
          {{else}}
            <p>goodbye</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "allows over-indented content in the else branch" do
        warnings = lint(<<~HBS)
          {{#if visible}}
            <p>hello</p>
          {{else}}
              <p>goodbye</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "allows content at same level as opener in else branch" do
        warnings = lint(<<~HBS)
          {{#if a}}
            <p>a</p>
          {{else}}
          <p>b</p>
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end
    end

    context "with deeply nested blocks" do
      it "passes a triple-nested correctly indented template" do
        warnings = lint(<<~HBS)
          {{#if a}}
            {{#each items}}
              {{#with author}}
                <span>{{name}}</span>
              {{/with}}
            {{/each}}
          {{/if}}
        HBS

        expect(warnings).to be_empty
      end

      it "catches a misindented line deep in nesting", :aggregate_failures do
        warnings = lint(<<~HBS)
          {{#if a}}
            {{#each items}}
              {{#with author}}
            <span>{{name}}</span>
              {{/with}}
            {{/each}}
          {{/if}}
        HBS

        expect(warnings.length).to eq(1)
        expect(warnings.first.line).to eq(4)
      end
    end
  end
end
