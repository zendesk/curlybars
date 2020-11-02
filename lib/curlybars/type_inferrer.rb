module Curlybars
  class TypeInferrer
    def initialize(source)
      @source = source
      @cache = {}
    end

    def infer_from(dependency_tree)
      visitor = Curlybars::Visitors::GenericHelperVisitor.new(dependency_tree)
      generic_helpers = Curlybars.visit(visitor, source)
      inferred_subtree = generic_helpers.entries.map do |path, node|
        [path, find_type_for_node(node, dependency_tree)]
      end.to_h
      dependency_tree.merge(inferred_subtree)
    end

    private

    attr_reader :source

    def find_type_for_node(node, dependency_tree)
      path = node.helper.path
      return @cache[path] if @cache[path]

      type = nil
      current_node = node
      intermediate_nodes = []
      while type.nil?
        intermediate_nodes << current_node
        inferrable_node = current_node.arguments.first
        if inferrable_node.is_a?(Curlybars::Node::SubExpression)
          current_node = inferrable_node
          next
        end

        type = dependency_tree[inferrable_node.path.to_sym]
      end

      intermediate_nodes.each { |inode| @cache.update(inode.helper.path => type) }

      type
    end
  end
end
