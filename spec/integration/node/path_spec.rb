describe "{{path}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "evaluates the methods chain call" do
      template = Curlybars.compile(<<-HBS)
        {{user.avatar.url}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
      HTML
    end

    it "{{../path}} is evaluated on the second to last context in the stack" do
      template = Curlybars.compile(<<-HBS)
        {{#with user.avatar}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "{{../../path}} is evaluated on the third to last context in the stack" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{#with avatar}}
            {{../../context}}
          {{/with}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "{{../path}} uses the right context, even when using the same name" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{#with avatar}}
            {{../context}}
          {{/with}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        user_context
        root_context
      HTML
    end

    it "a path with more `../` than the stack size will resolve to empty string" do
      template = Curlybars.compile(<<-HBS)
        {{context}}
        {{../context}}
        {{../../context}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "understands `this` as the current presenter" do
      template = Curlybars.compile(<<-HBS)
        {{user.avatar.url}}
        {{#with this}}
          {{user.avatar.url}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
        http://example.com/foo.png
      HTML
    end

    it "understands `../this` as the outer presenter" do
      template = Curlybars.compile(<<-HBS)
        {{#with user.avatar}}
          {{../context}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        root_context
      HTML
    end

    it "raises when trying to call methods not implemented on context" do
      template = Curlybars.compile(<<-HBS)
        {{not_in_whitelist}}
      HBS

      expect do
        eval(eval(template))
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
  end
end
