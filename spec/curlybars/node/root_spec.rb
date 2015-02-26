describe Curlybars::Node::Root do
  let(:file_name) { '/app/views/template.hbs' }

  it "compiles the template" do
    position = double(:position, file_name: file_name, line_number: 1, line_offset: 0)
    template = double(:template)
    expect(template).to receive(:compile)

    Curlybars::Node::Root.new(template, position).compile
  end
end
