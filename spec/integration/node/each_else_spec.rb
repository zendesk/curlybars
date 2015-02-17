describe "{{#each collection}}...{{else}}...{{/each}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "uses each_template when collection is not empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [:an_element] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each non_empty_collection}}
        each_template
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      each_template
    HTML
  end

  it "uses else_template when collection is not empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:empty_collection) { true }
    presenter.stub(:empty_collection) { [] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each empty_collection}}
        each_template
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      else_template
    HTML
  end

  it "uses each_template when collection is not empty" do
    element_presenter_class = Class.new(Curlybars::Presenter) do
      allow_methods :path
      def path
        'path'
      end
    end
    element_presenter = element_presenter_class.new(double(:this), {})

    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [element_presenter, element_presenter] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each non_empty_collection}}
        {{path}}
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      path
      path
    HTML
  end
end
