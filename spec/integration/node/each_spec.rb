describe "{{#each collection}}...{{/each}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "uses each_template when collection is not empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [:an_element] }

    template = compile(<<-HBS)
      {{#each non_empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      each_template
    HTML
  end

  it "doesn't use each_template when collection is empty" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:empty_collection) { true }
    presenter.stub(:empty_collection) { [] }

    template = compile(<<-HBS)
      {{#each empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "allows empty each_template" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [:an_element] }

    template = compile(<<-HBS)
      {{#each non_empty_collection}}{{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "uses each_template when collection is not empty" do
    path_presenter_class = Class.new(Curlybars::Presenter) do
      presents :path
      allow_methods :path
      def path
        @path
      end
    end

    a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
    another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

    IntegrationTest::Presenter.stub(:allows_method?).with(:non_empty_collection) { true }
    presenter.stub(:non_empty_collection) { [a_path_presenter, another_path_presenter] }

    template = compile(<<-HBS)
      {{#each non_empty_collection}}
        {{path}}
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      a_path
      another_path
    HTML
  end
end
