describe Curlybars::Error::Compile do
  let(:position) do
    OpenStruct.new(
      line_number: 2,
      line_offset: 3,
      stream_offset: 14,
      length: 3,
      file_name: 'template.hbs'
    )
  end

  it "prefixes the id with `compile.`" do
    id = 'id'

    exception = Curlybars::Error::Compile.new(id, 'message', position)

    expect(exception.id).to eq 'compile.%s' % id
  end
end
