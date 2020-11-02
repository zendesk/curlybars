module Curlybars
  module Visitors
    class GenericHelperVisitor < ::Curlybars::Visitor
      def initialize(dependency_tree)
        super([{}, {}])
        @dependency_tree = dependency_tree
      end

      def visit_sub_expression(node)
        path = node.helper.path.to_sym
        context.first.update(path => node) if generic_global_paths.include?(path)
        context.last.update(path => node) if generic_paths.include?(path)
        super(node)
      end

      private

      attr_reader :dependency_tree

      def generic_global_paths
        @generic_global_paths ||= generic_paths_from_tree(Curlybars.global_helpers_dependency_tree)
      end

      def generic_paths
        @generic_paths ||= generic_paths_from_tree(dependency_tree)
      end

      def generic_paths_from_tree(dep_tree)
        dep_nodes = dep_tree.entries.select do |_, type|
          type.is_a?(Array) && generic_collection?(type)
        end
        dep_nodes.map { |path, _| path }
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
