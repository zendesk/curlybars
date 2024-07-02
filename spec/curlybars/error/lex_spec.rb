describe Curlybars::Error::Lex do
  let(:file_name) { 'template.hbs' }

  let(:source) { "first_line\n0123456789\nthird_line" }

  let(:exception) do
    Struct.new(:line_number, :line_offset).new(2, 2)
  end

  it "creates an exception with a meaningful message" do
    message = ".. 01 `2` 3456789 .. is not permitted symbol in this context"

    lex_exception = Curlybars::Error::Lex.new(source, file_name, exception)

    expect(lex_exception.message).to eq message
  end

  it "figures out a position from the exception" do
    backtrace = "%s:%d:%d" % [file_name, exception.line_number, exception.line_offset]

    lex_exception = Curlybars::Error::Lex.new(source, file_name, exception)

    expect(lex_exception.backtrace).to eq [backtrace]
  end
end
