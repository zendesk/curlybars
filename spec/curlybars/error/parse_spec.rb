describe Curlybars::Error::Parse do
  let(:source) { "first_line\n0123456789\nthird_line" }

  describe "with current token not being EOS" do
    let(:position) do
      Struct.new(
        :line_number,
        :line_offset,
        :length,
        :file_name
      ).new(2, 3, 3, 'template.hbs')
    end

    let(:exception) do
      current = double(:current, position: position, type: :type)
      double(:exception, current: current)
    end

    it "creates an exception with a meaningful message" do
      message = ".. 012 `345` 6789 .. is not permitted in this context"

      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.message).to eq message
    end

    it "figures out a position from the exception" do
      backtrace = "%s:%d:%d" % [position.file_name, position.line_number, position.line_offset]

      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.backtrace).to eq [backtrace]
    end
  end

  describe "with current token being EOS" do
    let(:exception) do
      current = double(:current, position: nil, type: :EOS)
      double(:exception, current: current)
    end

    it "creates an exception with a meaningful message" do
      message = "A block helper hasn't been closed properly"

      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.message).to eq message
    end

    it "creates an exception whose position contains the right line_number" do
      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.position.line_number).to be 3
    end

    it "creates an exception whose position contains the right line_offset" do
      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.position.line_offset).to be_zero
    end

    it "creates an exception whose position contains the right length" do
      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.position.length).to be 'third_line'.length
    end

    it "creates an exception whose position contains a nil file_name" do
      lex_exception = Curlybars::Error::Parse.new(source, exception)

      expect(lex_exception.position.file_name).to be_nil
    end
  end
end
