module Curlybars
  module Node
    Text = Struct.new(:text) do
      def compile
        <<-RUBY
          buffer.concat(#{text.inspect}.html_safe)
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end

      def cache_key
        [
          text.to_s,
          self.class.name
        ].join("/")
      end
    end
  end
end
