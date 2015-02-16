require 'curlybars/error/incorrect_ending_error'

module Curlybars
  module Node
    class BlockHelper
      attr_reader :helper, :path, :template, :helperclose, :options

      def initialize(helper, path, template, helperclose, options = nil)
        if helper != helperclose
          raise Curlybars::Error::IncorrectEndingError,
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
              context = #{path.compile}.call
              helper = #{helper.compile}
              helper.call(*([context, options].first(helper.arity))) do
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
