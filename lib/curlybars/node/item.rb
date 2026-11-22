# frozen_string_literal: true

module Curlybars
  module Node
    Item = Struct.new(:item) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        CompiledMethods.define("item", "contexts, rendering, variables, buffer", <<-RUBY)
          rendering.check_timeout!
          #{item.compile}
        RUBY
      end

      def validate(branches, context: nil)
        item.validate(branches, context: context)
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def cache_key
        [
          item.cache_key,
          self.class.name
        ].join("/")
      end
    end
  end
end
