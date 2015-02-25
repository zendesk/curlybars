describe "{{#each collection}}...{{else}}...{{/each}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "uses each_template when collection is not empty" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [:an_element] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}
        each_template
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      each_template
    HTML
  end

  it "uses else_template when collection is not empty" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:empty_collection) { true }
    allow(presenter).to receive(:empty_collection) { [] }

    template = Curlybars.compile(<<-HBS)
      {{#each empty_collection}}
        each_template
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      else_template
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

    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [a_path_presenter, another_path_presenter] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}
        {{path}}
      {{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      a_path
      another_path
    HTML
  end

  it "allows empty each_template" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:empty_collection) { true }
    allow(presenter).to receive(:empty_collection) { [] }

    template = Curlybars.compile(<<-HBS)
      {{#each empty_collection}}{{else}}
        else_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      else_template
    HTML
  end

  it "allows empty else_template" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [:an_element] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}
        each_template
      {{else}}{{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      each_template
    HTML
  end

  it "allows empty each_template and else_template" do
    allow(IntegrationTest::Presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [:an_element] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}{{else}}{{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end
end
