describe Curlybars::DependencyTracker do
  it "returns the dependencies of the presenter for the given path" do
    presenter = Class.new(Curlybars::Presenter) do
      depends_on 'foo/bar', 'foo/baz'
    end

    allow(Curlybars::Presenter).to receive(:presenter_for_path).with("some/path").and_return(presenter)

    expect(described_class.call("some/path", "template source")).to eq(["foo/bar", "foo/baz"])
  end
end
