describe "{{#each collection}}...{{/each}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "uses each_template when collection is not empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [:an_element] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each non_empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      each_template
    HTML
  end

  it "doesn't use each_template when collection is empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:empty_collection) { true }
    presenter.stub(:empty_collection) { [] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
    HTML
  end

  it "uses each_template when collection is not empty" do
    ElementPresenter = Class.new(Curlybars::Presenter) do
      allow_methods :path
      def path
        'path'
      end
    end
    element_presenter = ElementPresenter.new(double(:this), {})

    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [element_presenter, element_presenter] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each non_empty_collection}}
        {{path}}
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      path
      path
    HTML
  end

  it "doesn't use each_tempalte to render the collection" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:empty_collection) { true }
    presenter.stub(:empty_collection) { [] }

    template = compile(<<-HBS.strip_heredoc)
      {{#each empty_collection}}
        {{path}}
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
    HTML
  end
end
