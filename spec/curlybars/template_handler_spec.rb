describe Curlybars::TemplateHandler do
  let :presenter_class do
    Class.new do
      def initialize(context, options = {})
        @context = context
        @cache_key = options.fetch(:cache_key, nil)
        @cache_duration = options.fetch(:cache_duration, nil)
        @cache_options = options.fetch(:cache_options, {})
      end

      def setup!
        @context.content_for(:foo, "bar")
      end

      def foo
        "FOO"
      end

      def bar
        @context.bar
      end

      def cache_key
        @cache_key
      end

      def cache_duration
        @cache_duration
      end

      def cache_options
        @cache_options
      end

      def allows_method?(method)
        true
      end
    end
  end

  let :context_class do
    Class.new do
      attr_reader :output_buffer
      attr_reader :local_assigns, :assigns

      def initialize
        @cache = Hash.new
        @local_assigns = Hash.new
        @assigns = Hash.new
        @clock = 0
      end

      def reset!
        @output_buffer = ActiveSupport::SafeBuffer.new
      end

      def advance_clock(duration)
        @clock += duration
      end

      def content_for(key, value = nil)
        @contents ||= {}
        @contents[key] = value if value.present?
        @contents[key]
      end

      def cache(key, options = {})
        fragment, expired_at = @cache[key]

        if fragment.nil? || @clock >= expired_at
          old_buffer = @output_buffer
          @output_buffer = ActiveSupport::SafeBuffer.new

          yield

          fragment = @output_buffer.to_s
          duration = options[:expires_in] || Float::INFINITY

          @cache[key] = [fragment, @clock + duration]

          @output_buffer = old_buffer
        end

        safe_concat(fragment)

        nil
      end

      def safe_concat(str)
        @output_buffer.safe_concat(str)
      end
    end
  end

  let(:template) { double("template", virtual_path: "test", identifier: "test.hbs") }
  let(:context) { context_class.new }

  before do
    stub_const("TestPresenter", presenter_class)
  end

  it "strips the `# encoding: *` directive away from the template" do
    output = render(<<~TEMPLATE)
      # encoding: utf-8"
      first line
    TEMPLATE
    expect(output).to eq(<<~TEMPLATE)

      first line
    TEMPLATE
  end

  it "passes in the presenter context to the presenter class" do
    allow(context).to receive(:bar).and_return("BAR")
    output = render("{{bar}}")
    expect(output).to eq("BAR")
  end

  it "fails if there's no matching presenter class" do
    allow(template).to receive(:virtual_path).and_return("missing")
    expect { render(" FOO ") }.to raise_exception(Curlybars::Error::Presenter::NotFound)
  end

  it "allows calling public methods on the presenter" do
    output = render("{{foo}}")
    expect(output).to eq("FOO")
  end

  it "marks its output as HTML safe" do
    output = render("{{foo}}")
    expect(output).to be_html_safe
  end

  it "calls the #setup! method before rendering the view" do
    render("{{foo}}")
    expect(context.content_for(:foo)).to eq("bar")
  end

  describe "caching" do
    before do
      allow(context).to receive(:bar).and_return("BAR")
    end

    let(:output) { -> { render("{{bar}}") } }

    it "caches the result with the #cache_key from the presenter" do
      context.assigns[:cache_key] = "x"
      expect(output.call).to eq("BAR")

      allow(context).to receive(:bar).and_return("BAZ")
      expect(output.call).to eq("BAR")

      context.assigns[:cache_key] = "y"
      expect(output.call).to eq("BAZ")
    end

    it "doesn't cache when the cache key is nil" do
      context.assigns[:cache_key] = nil
      expect(output.call).to eq("BAR")

      allow(context).to receive(:bar).and_return("BAZ")
      expect(output.call).to eq("BAZ")
    end

    it "adds the presenter class' cache key to the instance's cache key" do
      # Make sure caching is enabled
      context.assigns[:cache_key] = "x"

      allow(presenter_class).to receive(:cache_key).and_return("foo")

      expect(output.call).to eq("BAR")

      allow(presenter_class).to receive(:cache_key).and_return("bar")

      allow(context).to receive(:bar).and_return("FOOBAR")
      expect(output.call).to eq("FOOBAR")
    end

    it "expires the cache keys after #cache_duration" do
      context.assigns[:cache_key] = "x"
      context.assigns[:cache_duration] = 42

      expect(output.call).to eq("BAR")

      allow(context).to receive(:bar).and_return("FOO")

      # Cached fragment has not yet expired.
      context.advance_clock(41)
      expect(output.call).to eq("BAR")

      # Now it has! Huzzah!
      context.advance_clock(1)
      expect(output.call).to eq("FOO")
    end

    it "passes #cache_options to the cache backend" do
      context.assigns[:cache_key] = "x"
      context.assigns[:cache_options] = { expires_in: 42 }

      expect(output.call).to eq("BAR")

      allow(context).to receive(:bar).and_return("FOO")

      # Cached fragment has not yet expired.
      context.advance_clock(41)
      expect(output.call).to eq("BAR")

      # Now it has! Huzzah!
      context.advance_clock(1)
      expect(output.call).to eq("FOO")
    end
  end

  def render(source)
    code = Curlybars::TemplateHandler.call(template, source)

    context.reset!
    context.instance_eval(code)
  end
end
