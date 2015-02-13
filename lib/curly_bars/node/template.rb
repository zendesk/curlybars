module CurlyBars
  module Node
    Template = Struct.new(:items) do
      def compile
        items.map(&:compile).join("\n")
      end
    end
  end
end
