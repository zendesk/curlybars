describe Curlybars::RenderingSupport do
  let(:file_name) { '/app/views/template.hbs' }
  let(:presenter) { double(:presenter, allows_method?: true, meth: :value) }
  let(:contexts) { [presenter] }
  let(:variables) { [{}] }
  let(:rendering) { Curlybars::RenderingSupport.new(1.second, contexts, variables, file_name) }
  let(:position) do
    double(:position, file_name: 'template.hbs', line_number: 1, line_offset: 0)
  end
  let(:block) { -> {} }

  describe "#check_timeout!" do
    it "skips checking if timeout is nil" do
      rendering = Curlybars::RenderingSupport.new(nil, contexts, variables, file_name)

      sleep 0.1.seconds
      expect { rendering.check_timeout! }.not_to raise_error
    end

    it "doesn't happen when rendering is < rendering_timeout" do
      rendering = Curlybars::RenderingSupport.new(10.seconds, contexts, variables, file_name)
      expect { rendering.check_timeout! }.not_to raise_error
    end

    it "happens and raises when rendering >= rendering_timeout" do
      rendering = Curlybars::RenderingSupport.new(0.01.seconds, contexts, variables, file_name)

      sleep 0.1.seconds
      expect { rendering.check_timeout! }.to raise_error(Curlybars::Error::Render)
    end
  end

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
      allow(presenter).to receive(:method).and_return(:method)

      expect(rendering.path('method', rendering.position(0, 1))).to eq :method
    end

    it "returns the sub presenter method in the current context" do
      sub = double(:sub_presenter)
      allow_all_methods(sub)
      allow(sub).to receive(:method).and_return(:method)

      allow_all_methods(presenter)
      allow(presenter).to receive(:sub) { sub }

      expect(rendering.path('sub.method', rendering.position(0, 1))).to eq :method
    end

    it "returns the length of a collection, when `lenght` is the last step" do
      allow_all_methods(presenter)
      single_element_presenter = double(:single_element_presenter)
      allow_all_methods(single_element_presenter)
      collection = [single_element_presenter]
      allow(presenter).to receive(:collection) { collection }

      returned_method = rendering.path('collection.length', rendering.position(0, 1))
      expect(returned_method.call).to eq collection.length
    end

    it "raises an exception when the method is not allowed" do
      disallow_all_methods(presenter)
      allow(presenter).to receive(:forbidden_method).and_return(:forbidden_method)

      expect do
        rendering.path('forbidden_method', rendering.position(0, 1))
      end.to raise_error(Curlybars::Error::Render)
    end

    it "exposes the unallowed method in the exception payload" do
      disallow_all_methods(presenter)
      allow(presenter).to receive(:forbidden_method).and_return(:forbidden_method)

      begin
        rendering.path('forbidden_method', rendering.position(0, 1))
      rescue Curlybars::Error::Render => e
        expect(e.metadata).to eq(meth: :forbidden_method)
      end
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
      allow(sub).to receive(:method).and_return(:sub_method)

      allow_all_methods(presenter)
      allow(presenter).to receive(:method).and_return(:root_method)

      contexts.push(sub)

      expect(rendering.path('../method', rendering.position(0, 1))).to eq :root_method
    end

    it "refers to the third to last presenter in the stack when using `../../`" do
      sub_sub = double(:sub_presenter)
      allow_all_methods(sub_sub)
      allow(sub_sub).to receive(:method).and_return(:sub_sub_method)

      sub = double(:sub_presenter)
      allow_all_methods(sub)
      allow(sub).to receive(:method).and_return(:sub_method)

      allow_all_methods(presenter)
      allow(presenter).to receive(:method).and_return(:root_method)

      contexts.push(sub)
      contexts.push(sub_sub)

      expect(rendering.path('../../method', rendering.position(0, 1))).to eq :root_method
    end

    it "returns a method that returns nil, if nil is returned from any method in the chain (except the latter)" do
      allow_all_methods(presenter)
      allow(presenter).to receive(:returns_nil).and_return(nil)

      outcome = rendering.path('returns_nil.another_method', rendering.position(0, 1)).call
      expect(outcome).to be_nil
    end

    it "returns a method that returns nil, if `../`` goes too deep in the stack" do
      outcome = rendering.path('../too_deep', rendering.position(0, 1)).call
      expect(outcome).to be_nil
    end

    it "raises an exception if tha path is too deep (> 10)" do
      expect do
        rendering.path('a.b.c.d.e.f.g.h.i.l', rendering.position(0, 1))
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#cached_call" do
    before do
      class APresenter
        def meth
          :value
        end
      end
    end

    it "(cache miss) calls the method if not cached already" do
      meth = presenter.method(:meth)
      allow(meth).to receive(:call)

      rendering.cached_call(meth)

      expect(meth).to have_received(:call).once
    end

    it "(cache hit) avoids to call a method for more than one time" do
      meth = presenter.method(:meth)
      allow(meth).to receive(:call)

      rendering.cached_call(meth)
      rendering.cached_call(meth)

      expect(meth).to have_received(:call).once
    end

    it "the returned cached value is the same as the uncached one" do
      meth = presenter.method(:meth)

      first_outcome = rendering.cached_call(meth)
      second_outcome = rendering.cached_call(meth)

      expect(second_outcome).to eq first_outcome
    end
  end

  describe "#call" do
    it "calls with no arguments a method with no parameters" do
      method = -> { :return }
      arguments = []

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq :return
    end

    it "calls with one argument a method with no parameters, discarding the parameter" do
      method = -> { :return }
      arguments = [:argument]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq :return
    end

    it "calls a method with only one parameter can only receive the options" do
      method = ->(parameter) { parameter }
      arguments = []

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq :options
    end

    it "calls a method with only one parameter can only receive the options, even with some arguments" do
      method = ->(parameter) { parameter }
      arguments = [:argument]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq :options
    end

    it "calls a method with two parameter can receive nil as first argument and the options" do
      method = ->(parameter, options) { [parameter, options] }
      arguments = []

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq [nil, :options]
    end

    it "calls a method with two parameter can receive an argument and the options" do
      method = ->(parameter, options) { [parameter, options] }
      arguments = [:argument]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq [:argument, :options]
    end

    it "calls a method with three parameter can receive two arguments and the options" do
      method = ->(first, second, options) { [first, second, options] }
      arguments = [:first, :second]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq [:first, :second, :options]
    end

    it "calls a method with three parameter can receive one argument, nil and the options" do
      method = ->(first, second, options) { [first, second, options] }
      arguments = [:first]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq [:first, nil, :options]
    end

    it "calls a method with three parameter can receive nil, nil and the options" do
      method = ->(first, second, options) { [first, second, options] }
      arguments = []

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq [nil, nil, :options]
    end

    it "calls a method passing an array as argument" do
      method = ->(parameter, _) { parameter }
      array = [1, 2, 3]
      arguments = [array]

      output = rendering.call(method, "method", position, arguments, :options, &block)
      expect(output).to eq arguments.first
    end

    it "raises Curlybars::Error::Render if the helper has at least an optional parameter" do
      method = ->(one, two = :optional) {}
      arguments = [:arg1]
      options = { key: :value }

      expect do
        rendering.call(method, "method", position, arguments, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises Curlybars::Error::Render if the helper has at least a keyword parameter" do
      method = ->(keyword:) {}
      arguments = [:arg1]
      options = { key: :value }

      expect do
        rendering.call(method, "method", position, arguments, options, &block)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "raises Curlybars::Error::Render if the helper has at least an optional keyword parameter" do
      method = ->(keyword: :optional) {}
      arguments = [:arg1]
      options = { key: :value }

      expect do
        rendering.call(method, "meth", position, arguments, options, &block)
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

  describe "#coerce_to_hash!" do
    let(:a_presenter) { double(:a_presenter, allows_method?: true, meth: :value) }
    let(:another_presenter) { double(:another_presenter, allows_method?: true, meth: :value) }

    it "leaves hashes intacted" do
      hash = { first: a_presenter }
      expect(rendering.coerce_to_hash!(hash, 'path', position)).to be hash
    end

    it "transform an Array to a Hash" do
      array = [a_presenter, another_presenter]
      expected_hash = { 0 => a_presenter, 1 => another_presenter }
      expect(rendering.coerce_to_hash!(array, 'path', position)).to eq expected_hash
    end

    it "raises when it is not a hash or an enumerable" do
      expect do
        rendering.coerce_to_hash!(:not_a_presenter, 'path', position)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  private

  def allow_all_methods(presenter)
    allow(presenter).to receive(:allows_method?).and_return(true)
  end

  def disallow_all_methods(presenter)
    allow(presenter).to receive(:allows_method?).and_return(false)
  end
end
