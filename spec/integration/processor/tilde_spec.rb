# frozen_string_literal: true

describe "tilde operator" do
  let(:global_helpers_providers) { [] }
  let(:partial_provider) { nil }

  describe "compilation" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "{{~ ... }} removes trailing whitespaces and newlines from the previous :TEXT" do
      template = Curlybars.compile("before \r\t\n{{~'curlybars'}}\n\t\r after")

      expect(eval(template)).to resemble("beforecurlybars\n\t\r after")
    end

    it "{{ ... ~}} removes trailing whitespaces and newlines from the next :TEXT" do
      template = Curlybars.compile("before \r\t\n{{'curlybars'~}}\n\t\r after")

      expect(eval(template)).to resemble("before \r\t\ncurlybarsafter")
    end

    it "{{~ ... ~}} does not remove trailing whitespaces and newlines from the next :TEXT" do
      template = Curlybars.compile("before \r\t\n{{~'curlybars'~}}\n\t\r after")

      expect(eval(template)).to resemble("beforecurlybarsafter")
    end

    it "{{~ ... }} as the very first token does not look for a previous :TEXT" do
      template = Curlybars.compile("{{~'curlybars'}}\n\t\r after")

      expect(eval(template)).to resemble("curlybars\n\t\r after")
    end
  end

  describe "validation" do
    let(:presenter) { double(:presenter, dependency_tree: { curlybars: nil }) }

    it "runs even when 'run_processors' flag is set to false" do
      errors = Curlybars.validate(presenter.dependency_tree, "{{~curlybars~}}", run_processors: false)

      expect(errors).to be_empty
    end
  end
end
