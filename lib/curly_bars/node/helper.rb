require 'curly_bars/error/incorrect_ending_error'

module CurlyBars
  module Node
    class Helper
      attr_reader :helper, :path, :template, :helperclose, :options

      def initialize(helper, path, template, helperclose, options = nil)
        if helper != helperclose
          raise CurlyBars::Error::IncorrectEndingError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        end

        @helper = helper
        @path = path
        @template = template
        @helperclose = helperclose
        @options = options || {}
      end

      def compile
        compiled_options = <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
        RUBY

        compiled_options << options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          #{compiled_options}
          ActiveSupport::SafeBuffer.new begin
              context = #{path.compile}
              contexts.last.public_send(#{helper.inspect}.to_sym, context, options) do
                contexts << context
                begin
                  #{template.compile}
                ensure
                  contexts.pop
                end
              end
            end
        RUBY
      end
    end
  end
end
