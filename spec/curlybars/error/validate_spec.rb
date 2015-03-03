describe Curlybars::Error::Validate do
  let(:position) do
    OpenStruct.new(
      line_number: 2,
      line_offset: 3,
      stream_offset: 14,
      length: 3,
      file_name: 'template.hbs'
    )
  end

  it "prefixes the id with `validate.`" do
    id = 'id'

    exception = Curlybars::Error::Validate.new(id, 'message', position)

    expect(exception.id).to eq 'validate.%s' % id
  end
end
