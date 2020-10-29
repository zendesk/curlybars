describe "visitor" do
  let(:source) do
    <<-HBS
      {{#print_args_and_options 'first' 'second' key='value'}}
      {{/print_args_and_options}}

      {{calc (calc 1 "+" 2) "*" 3}}

      {{#render_inverse}}
        fn
      {{else}}
        inverse
        {{@variable}}
      {{/render_inverse}}

      {{#each foo}}
        top
        {{#each bar}}
          middle
          {{#each baz}}
            inner
          {{else}}
            inner inverse
          {{/each}}
        {{/each}}
      {{/each}}

      {{#if valid}}
        if_template
        {{#if bar}}
          foo
        {{else}}
          qux
        {{/if}}
      {{/if}}

      {{#if baz}}
        qux
      {{/if}}

      {{> partial}}

      {{user.avatar.url}}
      {{#with this}}
        {{user.avatar.url}}
      {{/with}}

      {{#unless things}}
        hi
      {{/unless}}
    HBS
  end

  describe ".visit" do
    it "visits BlockHelperElse nodes" do
      visitor = counting_visitor_for(Curlybars::Node::BlockHelperElse)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(5)
    end

    it "visits EachElse nodes" do
      visitor = counting_visitor_for(Curlybars::Node::EachElse)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(3)
    end

    it "visits IfElse nodes" do
      visitor = counting_visitor_for(Curlybars::Node::IfElse)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(3)
    end

    it "visits Item nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Item)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(44)
    end

    it "visits Literal nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Literal)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(8)
    end

    it "visits Option nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Option)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits Partial nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Partial)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits Path nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Path)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(15)
    end

    it "visits Root nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Root)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits SubExpression nodes" do
      visitor = counting_visitor_for(Curlybars::Node::SubExpression)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits Template nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Template)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(14)
    end

    it "visits Text nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Text)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(29)
    end

    it "visits UnlessElse nodes" do
      visitor = counting_visitor_for(Curlybars::Node::UnlessElse)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits Variable nodes" do
      visitor = counting_visitor_for(Curlybars::Node::Variable)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end

    it "visits WithElse nodes" do
      visitor = counting_visitor_for(Curlybars::Node::WithElse)
      output = Curlybars.visit(visitor, source)
      expect(output).to eq(1)
    end
  end

  def counting_visitor_for(klass)
    Class.new(Curlybars::Visitor) do
      define_method "visit_#{klass.name.demodulize.underscore}" do |node|
        self.context += 1
        super(node)
      end
    end.new(0)
  end
end
