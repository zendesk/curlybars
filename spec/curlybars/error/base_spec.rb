describe Curlybars::Error::Base do
  let(:position) do
    OpenStruct.new(line_number: 1, line_offset: 0)
  end

  it "creates an exception with the given message" do
    message = "message"

    exception = Curlybars::Error::Base.new(message, position)

    expect(exception.message).to be message
  end

  it "doesn't change the backtrace for nil position.file_name" do
    exception = Curlybars::Error::Base.new("message", position)

    expect(exception.backtrace).to be nil
  end

  it "sets the right backtrace for non-nil position.file_name" do
    position.file_name = 'template.hbs'

    exception = Curlybars::Error::Base.new("message", position)

    expect(exception.backtrace).not_to be nil
  end
end
