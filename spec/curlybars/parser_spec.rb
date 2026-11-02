describe Curlybars::Parser do
  def parse(source)
    described_class.parse(Curlybars::Lexer.lex(source))
  end

  describe "errors" do
    it "rejects a block that does not open with a keyword or a path", :aggregate_failures do
      expect { parse("{{#'foo'}}{{/foo}}") }.to raise_error(described_class::Error) do |error|
        expect(error.current.type).to eq :LITERAL
      end
    end
  end
end
