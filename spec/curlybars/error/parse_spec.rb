describe Curlybars::Error::Parse do
  let(:source) { "first_line\n0123456789\nthird_line" }

  let(:position) do
    OpenStruct.new(
      line_number: 2,
      line_offset: 3,
      stream_offset: 14,
      length: 3,
      file_name: 'template.hbs'
    )
  end

  let(:exception) do
    current = double(:current, position: position)
    double(:exception, current: current)
  end

  it "creates an exception with a meaningful message" do
    message = "Parsing error: `345` in `3456789` is not allowed"

    lex_exception = Curlybars::Error::Parse.new(source, exception)

    expect(lex_exception.message).to eq message
  end

  it "figures out a position from the exception" do
    backtrace = "%s:%d:%d" % [position.file_name, position.line_number, position.line_offset]

    lex_exception = Curlybars::Error::Parse.new(source, exception)

    expect(lex_exception.backtrace).to eq [backtrace]
  end
end
