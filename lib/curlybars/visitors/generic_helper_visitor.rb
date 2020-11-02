module Curlybars
  module Visitors
    class GenericHelperVisitor < ::Curlybars::Visitor
      def initialize(dependency_tree)
        super({})
        @dependency_tree = dependency_tree
      end

      def visit_sub_expression(node)
        path = node.helper.path.to_sym
        context.update(path => node) if generic_paths.include?(path)
        super(node)
      end

      private

      attr_reader :dependency_tree

      def generic_paths
        @generic_paths ||= begin
          dep_nodes = dependency_tree.entries.select do |_, type|
            type.is_a?(Array) &&
              generic_collection?(type)
          end
          dep_nodes.map { |path, _| path }
        end
      end

      def helper?(type)
        type.length == 2 && type.first == :helper
      end

      def generic_collection?(type)
        helper?(type) && type.last == [{}]
      end
    end
  end
end
