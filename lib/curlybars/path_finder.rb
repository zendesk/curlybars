module Curlybars
  class PathFinder
    def initialize(ast)
      @ast = ast
      @matches = []
    end

    def find(target_path)
      @matches = []
      @target_segments = normalize_path(target_path)
      traverse(@ast.template, [])
      @matches
    end

    private

    def normalize_path(path)
      return path if path.is_a?(Array)

      path.to_s.split('.')
    end

    def traverse(node, context_stack)
      return unless node

      case node
      when Curlybars::Node::Template
        node.items.each { |item| traverse(item, context_stack) }
      when Curlybars::Node::Item
        traverse(node.item, context_stack)
      when Curlybars::Node::Path
        check_path_match(node, context_stack)
      when Curlybars::Node::Output
        traverse(node.value, context_stack)
      when Curlybars::Node::Partial
        traverse(node.path, context_stack)
      when Curlybars::Node::SubExpression
        traverse(node.helper, context_stack)
        node.arguments&.each { |arg| traverse(arg, context_stack) }
        node.options&.each { |opt| traverse(opt.expression, context_stack) }
      when Curlybars::Node::BlockHelperElse
        handle_block_helper(node, context_stack)
      when Curlybars::Node::IfElse, Curlybars::Node::UnlessElse
        handle_conditional(node, context_stack)
      when Curlybars::Node::EachElse
        handle_each(node, context_stack)
      when Curlybars::Node::WithElse
        handle_with(node, context_stack)
      end
    end

    def check_path_match(path_node, context_stack)
      path_segments = path_node.path.split('.')
      resolved_segments = resolve_path(path_segments, context_stack)

      @matches << path_node if resolved_segments == @target_segments
    end

    def resolve_path(path_segments, context_stack)
      full_path = path_segments.join('.')
      stack = context_stack.dup

      # Handle ../ parent navigation
      while full_path.start_with?('../')
        full_path = full_path[3..]
        stack.pop unless stack.empty?
      end

      remaining_segments = full_path.empty? ? [] : full_path.split('.')
      stack + remaining_segments
    end

    def handle_block_helper(node, context_stack)
      traverse(node.helper, context_stack)
      traverse(node.helper_template, context_stack)
      traverse(node.else_template, context_stack) if node.else_template
      node.arguments&.each { |arg| traverse(arg, context_stack) }
      node.options&.each { |opt| traverse(opt.expression, context_stack) }
    end

    def handle_conditional(node, context_stack)
      traverse(node.expression, context_stack)

      if node.is_a?(Curlybars::Node::IfElse)
        traverse(node.if_template, context_stack)
      elsif node.is_a?(Curlybars::Node::UnlessElse)
        traverse(node.unless_template, context_stack)
      end
      traverse(node.else_template, context_stack) if node.else_template
    end

    def handle_each(node, context_stack)
      traverse(node.path, context_stack)

      # EachElse changes context to the item being iterated
      collection_path = node.path.respond_to?(:subexpression?) && node.path.subexpression? ? node.path.helper : node.path
      new_context = context_stack + collection_path.path.split('.')
      traverse(node.each_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end

    def handle_with(node, context_stack)
      traverse(node.path, context_stack)

      # WithElse changes context to the specified path
      presenter_path = node.path.respond_to?(:subexpression?) && node.path.subexpression? ? node.path.helper : node.path
      new_context = context_stack + presenter_path.path.split('.')
      traverse(node.with_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end
  end
end
