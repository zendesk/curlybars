describe "{{helper context key=value}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "works with objects" do
      template = Curlybars.compile(<<-HBS)
        {{json user}}
      HBS

      json = CGI.escapeHTML('{"user":{"id":2,"first_name":"Libo","locale":null}}')

      expect(eval(template)).to resemble(<<-HTML)
        #{json}
      HTML
    end

    it "works with collections" do
      template = Curlybars.compile(<<-HBS)
        {{json articles}}
      HBS

      json = CGI.escapeHTML('[{"article":{"id":1,"title":"A1","comment":"\u003cscript\u003ealert(\'bad\')\u003c/script\u003e","body":"This is \u003cstrong\u003eimportant\u003c/strong\u003e!","author":{"id":2,"first_name":"Libo","locale":null}}},{"article":{"id":1,"title":"A2","comment":"\u003cscript\u003ealert(\'bad\')\u003c/script\u003e","body":"This is \u003cstrong\u003eimportant\u003c/strong\u003e!","author":{"id":2,"first_name":"Libo","locale":null}}},{"article":{"id":1,"title":"B1","comment":"\u003cscript\u003ealert(\'bad\')\u003c/script\u003e","body":"This is \u003cstrong\u003eimportant\u003c/strong\u003e!","author":{"id":2,"first_name":"Libo","locale":null}}},{"article":{"id":1,"title":"B2","comment":"\u003cscript\u003ealert(\'bad\')\u003c/script\u003e","body":"This is \u003cstrong\u003eimportant\u003c/strong\u003e!","author":{"id":2,"first_name":"Libo","locale":null}}}]')

      expect(eval(template)).to resemble(<<-HTML)
        #{json}
      HTML
    end
  end
end
