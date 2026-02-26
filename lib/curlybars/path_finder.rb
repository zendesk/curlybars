module Curlybars
  class PathFinder
    def initialize(ast)
      @ast = ast
      @matches = []
    end

    # Find paths matching +target_path+.
    # +role:+ filters by syntactic role — :output, :helper, :argument, :option,
    # :condition, :collection, :scope, :partial, or an Array of these.
    def find(target_path, role: nil)
      @matches = []
      @target_segments = normalize_path(target_path)
      @role_filter = role
      traverse(@ast.template, [])
      @matches
    end

    private

    def normalize_path(path)
      return path if path.is_a?(Array)

      path.to_s.split('.')
    end

    def traverse(node, context_stack, role: nil)
      return unless node

      case node
      when Curlybars::Node::Template
        node.items.each { |item| traverse(item, context_stack) }
      when Curlybars::Node::Item
        traverse(node.item, context_stack)
      when Curlybars::Node::Path
        check_path_match(node, context_stack, role)
      when Curlybars::Node::Output
        traverse(node.value, context_stack, role: :output)
      when Curlybars::Node::Partial
        traverse(node.path, context_stack, role: :partial)
      when Curlybars::Node::SubExpression
        traverse(node.helper, context_stack, role: :helper)
        node.arguments&.each { |arg| traverse(arg, context_stack, role: :argument) }
        node.options&.each { |opt| traverse(opt.expression, context_stack, role: :option) }
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

    def check_path_match(path_node, context_stack, role)
      return unless matches_role?(role)

      path_segments = path_node.path.split('.')
      resolved_segments = resolve_path(path_segments, context_stack)

      @matches << path_node if resolved_segments == @target_segments
    end

    def matches_role?(role)
      return true if @role_filter.nil?

      if @role_filter.is_a?(Array)
        @role_filter.include?(role)
      else
        @role_filter == role
      end
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
      if simple_output?(node)
        traverse(node.helper, context_stack, role: :output)
      else
        traverse(node.helper, context_stack, role: :helper)
        node.arguments&.each { |arg| traverse(arg, context_stack, role: :argument) }
        node.options&.each { |opt| traverse(opt.expression, context_stack, role: :option) }
      end
      traverse(node.helper_template, context_stack)
      traverse(node.else_template, context_stack) if node.else_template
    end

    def simple_output?(block_helper)
      block_helper.arguments.empty? &&
        block_helper.options.empty? &&
        !block_helper.helper_template.is_a?(Curlybars::Node::Template)
    end

    def handle_conditional(node, context_stack)
      traverse(node.expression, context_stack, role: :condition)

      if node.is_a?(Curlybars::Node::IfElse)
        traverse(node.if_template, context_stack)
      elsif node.is_a?(Curlybars::Node::UnlessElse)
        traverse(node.unless_template, context_stack)
      end
      traverse(node.else_template, context_stack) if node.else_template
    end

    def handle_each(node, context_stack)
      traverse(node.path, context_stack, role: :collection)

      # EachElse changes context to the item being iterated
      collection_path = node.path.respond_to?(:subexpression?) && node.path.subexpression? ? node.path.helper : node.path
      new_context = context_stack + collection_path.path.split('.')
      traverse(node.each_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end

    def handle_with(node, context_stack)
      traverse(node.path, context_stack, role: :scope)

      # WithElse changes context to the specified path
      presenter_path = node.path.respond_to?(:subexpression?) && node.path.subexpression? ? node.path.helper : node.path
      new_context = context_stack + presenter_path.path.split('.')
      traverse(node.with_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end
  end
end
