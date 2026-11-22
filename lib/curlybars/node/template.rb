# frozen_string_literal: true

module Curlybars
  module Node
    Template = Struct.new(:items, :position) do
      def compile
        compiled_items = items.map(&:compile).join("\n")

        CompiledMethods.define("template", "contexts, rendering, variables, buffer", compiled_items)
      end

      def validate(branches, context: nil)
        items.map { |item| item.validate(branches, context: context) }
      end

      def cache_key
        Digest::MD5.hexdigest(items.map(&:cache_key).join("/"))
      end
    end
  end
end
