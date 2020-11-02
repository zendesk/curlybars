describe Curlybars::Visitors::GenericHelperVisitor do
  subject(:visitor) { described_class.new(dependecy_tree) }

  let(:dependecy_tree) do
    {
      a: [:helper, [{}]],
      b: [:helper, [{}]],
      c: [:helper, [{}]],
      collection: [{ attr: nil }]
    }
  end

  it "returns the subexpression nodes mapped to generic collection helper paths" do
    source = <<~HBS
      {{#each (a (b (c collection)))}}
        {{attr}}
      {{/each}}
    HBS
    nodes = Curlybars.visit(visitor, source)

    expect(nodes).to include(
      a: a_kind_of(Curlybars::Node::SubExpression),
      b: a_kind_of(Curlybars::Node::SubExpression),
      c: a_kind_of(Curlybars::Node::SubExpression)
    )
  end
end
