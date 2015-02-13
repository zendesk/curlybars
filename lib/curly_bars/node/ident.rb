module CurlyBars
  module Node
    Ident = Struct.new(:ident) do
      def compile
        <<-RUBY
          #{ident.to_s}
        RUBY
      end
    end
  end
end
