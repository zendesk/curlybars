module CurlyBars
  module Node
    With = Struct.new(:path, :template) do
      def compile
        <<-RUBY
          contexts << #{path.compile}
          begin
            ActiveSupport::SafeBuffer.new.safe_concat begin
              #{template.compile}
            end
          ensure
            contexts.pop
          end
        RUBY
      end
    end
  end
end
