describe Curlybars::Error::Render do
  let(:position) do
    OpenStruct.new(
      line_number: 2,
      line_offset: 3,
      stream_offset: 14,
      length: 3,
      file_name: 'template.hbs'
    )
  end

  it "prefixes the id with `render.`" do
    id = 'id'

    exception = Curlybars::Error::Render.new(id, 'message', position)

    expect(exception.id).to eq 'render.%s' % id
  end
end
