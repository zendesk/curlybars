module Curlybars
  module Node
    EachElse = Struct.new(:path, :each_template, :else_template, :position) do
      def compile
        <<-RUBY
          compiled_path = #{path.compile}.call

          #{check_context_is_array_of_presenters}

          if compiled_path.any?
            compiled_path.each do |presenter|
              contexts << presenter
              begin
                buffer.safe_concat(#{each_template.compile})
              ensure
                contexts.pop
              end
            end
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end

      private

      def check_context_is_array_of_presenters
        <<-RUBY
          array_of_presenters = compiled_path.respond_to?(:each) &&
            !compiled_path.detect do |context|
              !(context.respond_to? :allows_method?)
            end
          unless array_of_presenters
            position = hbs.position(#{position.line_number}, #{position.line_offset})
            message = "`#{path.path}` is not an array of presenters"
            raise Curlybars::Error::Render.new('context_is_not_an_array_of_presenters', message, position)
          end
        RUBY
      end
    end
  end
end
