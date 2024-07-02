describe Curlybars::Error::Compile do
  let(:position) do
    Struct.new(
      :line_number,
      :line_offset,
      :stream_offset,
      :length,
      :file_name
    ).new(2, 3, 14, 3, 'template.hbs')
  end

  it "prefixes the id with `compile.`" do
    id = 'id'

    exception = Curlybars::Error::Compile.new(id, 'message', position)

    expect(exception.id).to eq 'compile.%s' % id
  end
end
