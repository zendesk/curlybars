describe Curlybars::Node::Literal do
  it "compiles literal boolean true correctly" do
    compiled = Curlybars::Node::Literal.new(true).compile
    expect(instance_eval(compiled).call).to eq true
  end

  it "compiles literal boolean false correctly" do
    compiled = Curlybars::Node::Literal.new(false).compile
    expect(instance_eval(compiled).call).to eq false
  end

  it "compiles literal integer correctly" do
    compiled = Curlybars::Node::Literal.new(7).compile
    expect(instance_eval(compiled).call).to eq 7
  end

  it "compiles literal single quote correctly" do
    compiled = Curlybars::Node::Literal.new('"string"').compile
    expect(instance_eval(compiled).call).to eq 'string'
  end

  it "compiles literal double quote correctly" do
    compiled = Curlybars::Node::Literal.new('"string"').compile
    expect(instance_eval(compiled).call).to eq 'string'
  end
end
