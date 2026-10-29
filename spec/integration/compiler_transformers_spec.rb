# frozen_string_literal: true

describe "compiler transformers" do
  let(:transformer) { double(:transformer) }

  before do
    allow(Curlybars.configuration).to receive(:compiler_transformers).and_return([transformer])
    allow(transformer).to receive(:transform) { |source, _identifier| source.upcase }
  end

  it "transforms the source before compiling" do
    compiled = Curlybars.compile("text", "a/template")

    expect(compiled).to include("TEXT")
  end

  it "receives the source and the template identifier" do
    Curlybars.find("path", "{{path}}", "a/template")

    expect(transformer).to have_received(:transform).with("{{path}}", "a/template")
  end

  it "receives the source and the template identifier when visiting" do
    visitor = double(:visitor, accept: nil)

    Curlybars.visit(visitor, "{{path}}", "a/template")

    expect(transformer).to have_received(:transform).with("{{path}}", "a/template")
  end
end
