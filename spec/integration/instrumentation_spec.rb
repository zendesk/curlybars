describe "parse.curlybars instrumentation" do
  let(:payloads) { [] }

  around do |example|
    callback = ->(*, payload) { payloads << payload }
    ActiveSupport::Notifications.subscribed(callback, "parse.curlybars") { example.run }
  end

  it "reports the nesting depth of a parsed template" do
    Curlybars.compile("{{#each a}}{{#if b}}{{h (s x)}}{{/if}}{{/each}}", "a/template")

    expect(payloads.last).to include(
      identifier: "a/template",
      depth_limit: Curlybars::Parser::DEFAULT_PARSE_DEPTH_LIMIT,
      max_depth: 3
    )
  end

  it "is emitted when validating" do
    Curlybars.validate({}, "text", "a/template")

    expect(payloads.last).to include(identifier: "a/template")
  end

  it "reports templates rejected for exceeding the depth limit", :aggregate_failures do
    Curlybars.configuration.parse_depth_limit = 2
    source = "{{#if a}}{{#if b}}{{#if c}}{{/if}}{{/if}}{{/if}}"

    expect { Curlybars.compile(source) }.to raise_error(Curlybars::Error::Parse)
    expect(payloads.last).to include(depth_limit: 2, max_depth: 2)
    expect(payloads.last[:exception_object]).to be_a(Curlybars::Parser::ParseDepthExceeded)
  ensure
    Curlybars.reset
  end
end
