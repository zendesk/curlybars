describe Curlybars::Node::Root do
  let(:file_name) { '/app/views/template.hbs' }

  it "compiles the template" do
    position = double(:position, file_name: file_name, line_number: 1, line_offset: 0)
    template = double(:template)
    expect(template).to receive(:compile)

    Curlybars::Node::Root.new(template, position).compile
  end

  describe "hbs helper class" do
    let(:presenter) { double(:presenter) }
    let(:contexts) { [presenter] }
    let(:hbs) { eval(Curlybars::Node::Root.hbs).new(contexts, file_name) }

    describe "#to_bool" do
      describe "returns true" do
        it "with `true`" do
          expect(hbs.to_bool(true)).to be_truthy
        end

        it "with `[:non_empty]`" do
          expect(hbs.to_bool([:non_empty])).to be_truthy
        end

        it "with `1`" do
          expect(hbs.to_bool(1)).to be_truthy
        end
      end

      describe "returns false" do
        it "with `false`" do
          expect(hbs.to_bool(false)).to be_falsey
        end

        it "with `[]`" do
          expect(hbs.to_bool([])).to be_falsey
        end

        it "with `0`" do
          expect(hbs.to_bool(0)).to be_falsey
        end

        it "with `nil`" do
          expect(hbs.to_bool(nil)).to be_falsey
        end
      end
    end

    describe "#path" do
      it "returns the method in the current context" do
        allow_all_methods(presenter)
        allow(presenter).to receive(:method) { :method }

        expect(hbs.path('method', hbs.position(0, 1))).to eq :method
      end

      it "returns the method in the current context" do
        sub = double(:sub_presenter)
        allow_all_methods(sub)
        allow(sub).to receive(:method) { :method }

        allow_all_methods(presenter)
        allow(presenter).to receive(:sub) { sub }

        expect(hbs.path('sub.method', hbs.position(0, 1))).to eq :method
      end

      it "raises an exception when the method is not allowed" do
        disallow_all_methods(presenter)
        allow(presenter).to receive(:forbidden_method) { :forbidden_method }

        expect do
          hbs.path('forbidden_method', hbs.position(0, 1))
        end.to raise_error(Curlybars::Error::Render)
      end
    end

    describe "#position" do
      it "returns a position with file_name" do
        position = hbs.position(0, 0)
        expect(position.file_name).to eq file_name
      end

      it "returns a position with line_number" do
        position = hbs.position(1, 0)
        expect(position.line_number).to eq 1
      end

      it "returns a position with line_offset" do
        position = hbs.position(0, 1)
        expect(position.line_offset).to eq 1
      end
    end
  end

  private

  def allow_all_methods(presenter)
    allow(presenter).to receive_message_chain(:class, :allows_method?) { true }
  end

  def disallow_all_methods(presenter)
    allow(presenter).to receive_message_chain(:class, :allows_method?) { false }
  end
end
