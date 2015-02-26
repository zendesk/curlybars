require 'curlybars/error/compile'

module Curlybars
  module Node
    BlockHelper = Struct.new(:helper, :context, :options, :template, :helperclose, :position) do
      def initialize(helper, context, options, template, helperclose, position)
        if helper.path != helperclose.path
          message = "block `#{helper.path}` cannot be closed by `#{helperclose.path}`"
          raise Curlybars::Error::Compile.new('closing_tag_mismatch', message, helperclose.position)
        end
        super
      end

      def compile
        compiled_options = (options || []).map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        <<-RUBY
          options = ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}
          result = begin
              context = #{context.compile}.call

              #{check_context_is_presenter}
              
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
          buffer.safe_concat(result.to_s)
        RUBY
      end

      private

      def check_context_is_presenter
        <<-RUBY
          unless context.class.respond_to? :allows_method?
            position = hbs.position(#{position.line_number}, #{position.line_offset})
            message = "`#{context.path}` is not a context type object"
            raise Curlybars::Error::Render.new('context_is_not_a_presenter', message, position)
          end
        RUBY
      end
    end
  end
end
