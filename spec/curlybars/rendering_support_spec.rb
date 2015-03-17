describe Curlybars::RenderingSupport do
  let(:file_name) { '/app/views/template.hbs' }
  let(:presenter) { double(:presenter, allows_method?: true) }
  let(:contexts) { [presenter] }
  let(:variables) { [{}] }
  let(:rendering) { Curlybars::RenderingSupport.new(contexts, variables, file_name) }
  let(:position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0)
  end
  let(:block) { -> {} }

  describe "#to_bool" do
    describe "returns true" do
      it "with `true`" do
        expect(rendering.to_bool(true)).to be_truthy
      end

      it "with `[:non_empty]`" do
        expect(rendering.to_bool([:non_empty])).to be_truthy
      end

      it "with `1`" do
        expect(rendering.to_bool(1)).to be_truthy
      end
    end

    describe "returns false" do
      it "with `false`" do
        expect(rendering.to_bool(false)).to be_falsey
      end

      it "with `[]`" do
        expect(rendering.to_bool([])).to be_falsey
      end

      it "with `{}`" do
        expect(rendering.to_bool({})).to be_falsey
      end

      it "with `0`" do
        expect(rendering.to_bool(0)).to be_falsey
      end

      it "with `nil`" do
        expect(rendering.to_bool(nil)).to be_falsey
      end
    end
  end

  describe "#path" do
    it "returns the method in the current context" do
      allow_all_methods(presenter)
      allow(presenter).to receive(:method) { :method }

      expect(rendering.path('method', rendering.position(0, 1))).to eq :method
    end

    it "returns the method in the current context" do
      sub = double(:sub_presenter)
      allow_all_methods(sub)
      allow(sub).to receive(:method) { :method }

      allow_all_methods(presenter)
      allow(presenter).to receive(:sub) { sub }

      expect(rendering.path('sub.method', rendering.position(0, 1))).to eq :method
    end

    it "raises an exception when the method is not allowed" do
      disallow_all_methods(presenter)
      allow(presenter).to receive(:forbidden_method) { :forbidden_method }

      expect do
        rendering.path('forbidden_method', rendering.position(0, 1))
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises an exception when the context is not a presenter" do
      sub = double(:not_presenter)
      allow(presenter).to receive(:sub) { sub }

      expect do
        rendering.path('sub.method', rendering.position(0, 1))
      end.to raise_error(Curlybars::Error::Render)
    end

    it "refers to the second to last presenter in the stack when using `../`" do
      sub = double(:sub_presenter)
      allow_all_methods(sub)
      allow(sub).to receive(:method) { :sub_method }

      allow_all_methods(presenter)
      allow(presenter).to receive(:method) { :root_method }

      contexts.push(sub)

      expect(rendering.path('../method', rendering.position(0, 1))).to eq :root_method
    end

    it "refers to the third to last presenter in the stack when using `../../`" do
      sub_sub = double(:sub_presenter)
      allow_all_methods(sub_sub)
      allow(sub_sub).to receive(:method) { :sub_sub_method }

      sub = double(:sub_presenter)
      allow_all_methods(sub)
      allow(sub).to receive(:method) { :sub_method }

      allow_all_methods(presenter)
      allow(presenter).to receive(:method) { :root_method }

      contexts.push(sub)
      contexts.push(sub_sub)

      expect(rendering.path('../../method', rendering.position(0, 1))).to eq :root_method
    end

    it "returns a method that returns nil, if nil is returned from any method in the chain (except the latter)" do
      allow_all_methods(presenter)
      allow(presenter).to receive(:returns_nil) { }

      outcome = rendering.path('returns_nil.another_method', rendering.position(0, 1)).call
      expect(outcome).to be_nil
    end

    it "returns a method that returns nil, if `../`` goes too deep in the stack" do
      allow_all_methods(presenter)
      allow(presenter).to receive(:returns_nil) { }

      outcome = rendering.path('../too_deep', rendering.position(0, 1)).call
      expect(outcome).to be_nil
    end
  end

  describe "#call" do
    let(:context) { 'context' }
    let(:options) { { key: :value } }

    it "passes context and options to a helper that accepts both" do
      method = ->(context, options) { [context, options] }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq [context, options]
    end

    it "allows options to be ignored" do
      method = ->(context, _) { [context] }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq [context]
    end

    it "allows context to be ignored" do
      method = ->(_, options) { [options] }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq [options]
    end

    it "allows to ignore both context and options" do
      method = ->(_, _) { :nothing }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq :nothing
    end

    it "allows to accept only one parameter, that will be the context" do
      method = ->(context) { [context] }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq [context]
    end

    it "allows to have no parameters at all" do
      method = ->() { :nothing  }

      output = rendering.call(method, "meth", position, context, options, &block)
      expect(output).to eq :nothing
    end

    it "raises Curlybars::Error::Render if the helper has more than 2 parameters" do
      method = ->(one, two, three) { }

      expect do
        rendering.call(method, "meth", position, context, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises Curlybars::Error::Render if the helper has at least an optional parameter" do
      method = ->(one, two = :optional) { }

      expect do
        rendering.call(method, "meth", position, context, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises Curlybars::Error::Render if the helper has at least a keyword parameter" do
      method = ->(one, keyword:) { }

      expect do
        rendering.call(method, "meth", position, context, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises Curlybars::Error::Render if the helper has at least an optional keyword parameter" do
      method = ->(one, keyword: :optional) { }

      expect do
        rendering.call(method, "meth", position, context, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#position" do
    it "returns a position with file_name" do
      position = rendering.position(0, 0)
      expect(position.file_name).to eq file_name
    end

    it "returns a position with line_number" do
      position = rendering.position(1, 0)
      expect(position.line_number).to eq 1
    end

    it "returns a position with line_offset" do
      position = rendering.position(0, 1)
      expect(position.line_offset).to eq 1
    end
  end

  describe "#check_context_is_hash_or_enum_of_presenters" do
    it "doesn't raise an exception when argument is an empty enumerable" do
      collection = []
      rendering.check_context_is_hash_or_enum_of_presenters(collection, 'path', position)
    end

    it "doesn't raise an exception when argument is an empty hash" do
      collection = {}
      rendering.check_context_is_hash_or_enum_of_presenters(collection, nil, position)
    end

    it "doesn't raise an exception when argument is an enumerable of presenters" do
      collection = [presenter]
      rendering.check_context_is_hash_or_enum_of_presenters(collection, 'path', position)
    end

    it "doesn't raise an exception when argument is a hash of presenters" do
      collection = { presenter: presenter }
      rendering.check_context_is_hash_or_enum_of_presenters(collection, 'path', position)
    end

    it "raises when it is not an hash or an enumerable" do
      expect do
        rendering.check_context_is_hash_or_enum_of_presenters(:not_a_presenter, 'path', position)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises when it is not an hash or an enumerable of presenters" do
      expect do
        rendering.check_context_is_hash_or_enum_of_presenters([:not_a_presenter], 'path', position)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#check_context_is_presenter" do
    it "doesn't raise an exception when argument is a presenter" do
      rendering.check_context_is_presenter(presenter, 'path', position)
    end

    it "raises when it is not a presenter" do
      expect do
        rendering.check_context_is_presenter(:not_a_presenter, 'path', position)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#coerce_to_hash" do
    it "leaves hashes intacted" do
      hash = { key: :value }
      expect(rendering.coerce_to_hash(hash, 'path', position)).to be hash
    end

    it "transform an Array to a Hash" do
      array = [:a, :b, :c]
      expected_hash = { 0 => :a, 1 => :b, 2 => :c }
      expect(rendering.coerce_to_hash(array, 'path', position)).to eq expected_hash
    end

    it "raises when it is not a hash or an enumerable" do
      expect do
        rendering.coerce_to_hash(:not_a_presenter, 'path', position)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  private

  def allow_all_methods(presenter)
    allow(presenter).to receive(:allows_method?) { true }
  end

  def disallow_all_methods(presenter)
    allow(presenter).to receive(:allows_method?) { false }
  end
end
