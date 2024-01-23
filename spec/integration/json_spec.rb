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
  end
end
