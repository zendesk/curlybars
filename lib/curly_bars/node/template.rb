module CurlyBars
  module Node
    Template = Struct.new(:items) do
      def compile
        compiled_items = items.map do |item|
          <<-RUBY
            buffer.safe_concat begin
              #{item.compile}
            end
          RUBY
        end.join("\n")

        <<-RUBY
          begin
            buffer = ActiveSupport::SafeBuffer.new
            #{compiled_items}
            buffer
          end
        RUBY
      end
    end
  end
end
