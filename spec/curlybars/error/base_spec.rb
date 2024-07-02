describe Curlybars::Error::Base do
  let(:position) do
    Struct.new(:line_number, :line_offset, :file_name).new(1, 0, nil)
  end

  it "creates an exception with the given message" do
    message = "message"

    exception = Curlybars::Error::Base.new('id', message, position)

    expect(exception.message).to be message
  end

  it "doesn't change the backtrace for nil position.file_name" do
    exception = Curlybars::Error::Base.new('id', 'message', position)

    expect(exception.backtrace).to be nil
  end

  it "sets the right backtrace for non-nil position.file_name" do
    position.file_name = 'template.hbs'

    exception = Curlybars::Error::Base.new('id', 'message', position)

    expect(exception.backtrace).not_to be nil
  end

  it "sets the position as an instance varaible" do
    exception = Curlybars::Error::Base.new('id', 'message', position)

    expect(exception.position).to be position
  end

  it "sets the id as an instance varaible" do
    id = 'id'

    exception = Curlybars::Error::Base.new(id, 'message', position)

    expect(exception.id).to be id
  end
end
