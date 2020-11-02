module Curlybars
  class TypeInferrer
    class << self
      def infer_from_node(subexpression, dependency_tree)
        unified_dependency_tree = dependency_tree.merge(Curlybars.global_helpers_dependency_tree)
        find_type_for_node(subexpression, unified_dependency_tree)
      end

      def find_type_for_node(node, dependency_tree)
        path = node.helper.path

        type = nil
        current_node = node
        while type.nil?
          validate_helper!(current_node)

          inferrable_node = current_node.arguments.first
          if inferrable_node.is_a?(Curlybars::Node::SubExpression)
            current_node = inferrable_node
            next
          end

          type = dependency_tree[inferrable_node.path.to_sym]
          break
        end

        validate_type!(type, dependency_tree[path.to_sym].last, current_node)

        type
      end

      private

      def validate_helper!(subexpression)
        helper = subexpression.helper

        if subexpression.arguments.empty?
          raise Curlybars::Error::Validate.new('missing_path', "'#{helper.path}' requires a collection as its first argument", helper.position)
        end
      end

      def validate_type!(type, expected_type, subexpression)
        expected = expected_type.class
        actual = type.class

        unless actual == expected
          unallowed_path = subexpression.arguments.first.path
          position = subexpression.arguments.first.position
          raise Curlybars::Error::Validate.new('unallowed_path', "'#{unallowed_path}' is not a collection", position)
        end
      end
    end

    def initialize(source)
      @source = source
      @cache = {}
    end

    def infer_from(dependency_tree)
      visitor = Curlybars::Visitors::GenericHelperVisitor.new(dependency_tree)
      generic_global_helpers, generic_helpers = Curlybars.visit(visitor, source)
      unified_dependency_tree = dependency_tree.merge(Curlybars.global_helpers_dependency_tree)

      generic_global_helpers.entries.each do |path, node|
        self.class.find_type_for_node(node, unified_dependency_tree)
      end
      inferred_subtree = generic_helpers.entries.map do |path, node|
        [path, self.class.find_type_for_node(node, unified_dependency_tree)]
      end.to_h

      dependency_tree.merge(inferred_subtree)
    end

    private

    attr_reader :source
  end
end
