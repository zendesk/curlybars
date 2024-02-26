describe "{{json arg1}}" do
  let(:global_helpers_providers) { [IntegrationTest::GlobalHelperProvider.new] }

  describe "#compile" do
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context")) }

    it "renders a script tag using the json helper when rendering an array" do
      template = Curlybars.compile(<<-HBS)
        <script>
          const articles = {{json articles}}
        </script>
      HBS

      expected_output = <<-HTML
        <script>
          const articles = [{"title":"A1","comment":"\\u003cscript\\u003ealert('bad')\\u003c/script\\u003e","body":"This is \\u003cstrong\\u003eimportant\\u003c/strong\\u003e!","author":{"first_name":"Libo","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png"},"context":"user_context","me":"[circular reference]"}},{"title":"A2","comment":"\\u003cscript\\u003ealert('bad')\\u003c/script\\u003e","body":"This is \\u003cstrong\\u003eimportant\\u003c/strong\\u003e!","author":{"first_name":"Libo","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png"},"context":"user_context","me":"[circular reference]"}},{"title":"B1","comment":"\\u003cscript\\u003ealert('bad')\\u003c/script\\u003e","body":"This is \\u003cstrong\\u003eimportant\\u003c/strong\\u003e!","author":{"first_name":"Libo","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png"},"context":"user_context","me":"[circular reference]"}},{"title":"B2","comment":"\\u003cscript\\u003ealert('bad')\\u003c/script\\u003e","body":"This is \\u003cstrong\\u003eimportant\\u003c/strong\\u003e!","author":{"first_name":"Libo","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png"},"context":"user_context","me":"[circular reference]"}}]
        </script>
      HTML

      expect(eval(template)).to eq(expected_output)
    end

    it "renders a script tag using the json helper when rendering an object" do
      template = Curlybars.compile(<<-HBS)
        <script>
          const articles = {{json article}}
        </script>
      HBS

      expected_output = <<-HTML
        <script>
          const articles = {"title":"The Prince","comment":"\\u003cscript\\u003ealert('bad')\\u003c/script\\u003e","body":"This is \\u003cstrong\\u003eimportant\\u003c/strong\\u003e!","author":{"first_name":"Nicolò","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png"},"context":"user_context","me":"[circular reference]"}}
        </script>
      HTML

      expect(eval(template)).to resemble(expected_output)
    end

    it "renders a script tag using the json helper when rendering a string" do
      template = Curlybars.compile(<<-HBS)
        <script>
          const articles = {{json article.title}}
        </script>
      HBS

      expected_output = <<-HTML
        <script>
          const articles = "The Prince"
        </script>
      HTML

      expect(eval(template)).to resemble(expected_output)
    end

    it "renders a script tag using the json helper when rendering a normal helper" do
      template = Curlybars.compile(<<-HBS)
        <script>
          const bar = {{json bar}}
        </script>
      HBS

      expected_output = <<-HTML
        <script>
          const bar = "LOL"
        </script>
      HTML

      expect(eval(template)).to resemble(expected_output)
    end

    describe "subexpressions" do
      it "serializes the result of inline subexpressions that receive an object" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const user = {{json (translate user "en-DK")}}
          </script>
        HBS

        expected_output = <<-HTML
          <script>
            const user = {"first_name":"Libo","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png?locale=en-DK"},"context":"user_context","me":"[circular reference]"}
          </script>
        HTML

        expect(eval(template)).to resemble(expected_output)
      end

      it "serializes the result of inline subexpressions that receive a nested object" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const author = {{json (translate article.author "en-DK")}}
          </script>
        HBS

        expected_output = <<-HTML
          <script>
            const author = {"first_name":"Nicolò","created_at":"2015-02-03T13:25:06.000+00:00","avatar":{"url":"http://example.com/foo.png?locale=en-DK"},"context":"user_context","me":"[circular reference]"}
          </script>
        HTML

        expect(eval(template)).to resemble(expected_output)
      end

      it "serializes the result of inline subexpressions" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const three = {{json (calc 1 "+" 2)}}
          </script>
        HBS

        expected_output = <<-HTML
          <script>
            const three = 3
          </script>
        HTML

        expect(eval(template)).to resemble(expected_output)
      end

      it "serializes the result of nested inline subexpressions" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const nine = {{json (calc (calc 1 "+" 2) "*" 3)}}
          </script>
        HBS

        expected_output = <<-HTML
          <script>
            const nine = 9
          </script>
        HTML

        expect(eval(template)).to resemble(expected_output)
      end

      it "serialize the result of normal helpers" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const bar = {{json (bar)}}
          </script>
        HBS

        expected_output = <<-HTML
          <script>
            const bar = "LOL"
          </script>
        HTML

        expect(eval(template)).to resemble(expected_output)
      end
    end

    describe "validation" do
      it "validates unallowed methods" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const articles = {{json unallowed}}
          </script>
        HBS

        expect do
          eval(template)
        end.to raise_error(Curlybars::Error::Render, "`unallowed` is not available - add `allow_methods :unallowed` to IntegrationTest::Presenter to allow this path")
      end

      it "validates nested unallowed methods" do
        template = Curlybars.compile(<<-HBS)
          <script>
            const articles = {{json article.unallowed}}
          </script>
        HBS

        expect do
          eval(template)
        end.to raise_error(Curlybars::Error::Render, "`unallowed` is not available - add `allow_methods :unallowed` to Shared::ArticlePresenter to allow this path")
      end
    end
  end
end
