describe Curlybars::Parser do
  def parse(source, **options)
    described_class.parse(Curlybars::Lexer.lex(source), **options)
  end

  describe "depth limit" do
    let(:limit) { described_class::DEFAULT_PARSE_DEPTH_LIMIT }

    it "accepts blocks nested up to the limit" do
      source = ("{{#if x}}" * limit) + ("{{/if}}" * limit)

      expect(parse(source)).to be_a(Curlybars::Node::Root)
    end

    it "rejects blocks nested beyond the limit" do
      source = ("{{#if x}}" * (limit + 1)) + ("{{/if}}" * (limit + 1))

      expect { parse(source) }.to raise_error(described_class::ParseDepthExceeded)
    end

    it "rejects subexpressions nested beyond the limit" do
      source = "{{h #{'(s ' * (limit + 1)}a#{')' * (limit + 1)}}}"

      expect { parse(source) }.to raise_error(described_class::ParseDepthExceeded)
    end

    it "counts blocks and subexpressions together" do
      blocks = limit / 2
      subexpressions = limit - blocks + 1
      source = ("{{#if x}}" * blocks) + "{{h #{'(s ' * subexpressions}a#{')' * subexpressions}}}" + ("{{/if}}" * blocks)

      expect { parse(source) }.to raise_error(described_class::ParseDepthExceeded)
    end

    it "accepts a custom limit", :aggregate_failures do
      source = ("{{#if x}}" * 3) + ("{{/if}}" * 3)

      expect(parse(source, depth_limit: 3)).to be_a(Curlybars::Node::Root)
      expect { parse(source, depth_limit: 2) }.to raise_error(described_class::ParseDepthExceeded) do |error|
        expect(error.limit).to eq 2
      end
    end

    it "reports the opening tag of the block that is too deep", :aggregate_failures do
      source = ("{{#if x}}\n" * (limit + 1)) + ("{{/if}}" * (limit + 1))

      expect { Curlybars.compile(source) }.to raise_error(Curlybars::Error::Parse) do |error|
        expect(error.message).to eq "Blocks and subexpressions cannot be nested more than #{limit} levels deep"
        expect(error.position.line_number).to eq limit + 1
      end
    end

    it "uses the configured parse_depth_limit" do
      Curlybars.configuration.parse_depth_limit = limit + 1
      source = ("{{#if x}}" * (limit + 1)) + ("{{/if}}" * (limit + 1))

      expect { Curlybars.compile(source) }.not_to raise_error
    ensure
      Curlybars.reset
    end
  end

  describe "errors" do
    it "rejects a block that does not open with a keyword or a path", :aggregate_failures do
      expect { parse("{{#'foo'}}{{/foo}}") }.to raise_error(described_class::Error) do |error|
        expect(error.current.type).to eq :LITERAL
      end
    end
  end

  describe "depth tracking" do
    def parser_for(source)
      described_class.new(Curlybars::Lexer.lex(source)).tap(&:parse)
    end

    it "is zero for a template without blocks or subexpressions" do
      parser = parser_for("{{a}} text {{b c}}")

      expect(parser.max_depth).to eq 0
    end

    it "tracks the deepest nesting of blocks and subexpressions" do
      parser = parser_for("{{#if a}}{{#if b}}{{h (s (t x))}}{{/if}}{{/if}}{{#if c}}{{/if}}")

      expect(parser.max_depth).to eq 4
    end
  end
end
