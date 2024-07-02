describe Curlybars::Error::Render do
  let(:position) do
    Struct.new(
      :line_number,
      :line_offset,
      :stream_offset,
      :length,
      :file_name
    ).new(2, 3, 14, 3, 'template.hbs')
  end

  it "prefixes the id with `render.`" do
    id = 'id'

    exception = Curlybars::Error::Render.new(id, 'message', position)

    expect(exception.id).to eq 'render.%s' % id
  end
end
