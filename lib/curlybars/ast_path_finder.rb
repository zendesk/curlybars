module Curlybars
  # frozen_string_literal: true

  # Finds all nodes in a Curlybars AST that resolve to a given path,
  # taking into account contextual scope from block helpers like #with, #each, #if, etc.
  class AstPathFinder
    # @param ast [Curlybars::Node::Root] The parsed AST
    def initialize(ast)
      @ast = ast
      @matches = []
    end

    # Find all nodes that resolve to the given path
    # @param target_path [String, Array<String>] The path to search for, e.g., "section.name" or ["section", "name"]
    # @return [Array<Hash>] Array of matches with :node, :position, :resolved_path, :context
    def find(target_path)
      @matches = []
      @target_segments = normalize_path(target_path)

      traverse(@ast.template, [])

      @matches
    end

    private

    # Normalize path input to array of segments
    def normalize_path(path)
      return path if path.is_a?(Array)

      path.to_s.split('.')
    end

    # Main traversal method - walks the AST with context tracking
    def traverse(node, context_stack)
      return unless node

      case node
      when Curlybars::Node::Template
        # Template contains array of items
        node.items.each { |item| traverse(item, context_stack) }

      when Curlybars::Node::Item
        # Item wraps another node
        traverse(node.item, context_stack)

      when Curlybars::Node::Path
        # This is a path reference - check if it matches our target
        check_path_match(node, context_stack)

      when Curlybars::Node::BlockHelperElse
        # Block helpers like {{#with}}, {{#each}}, {{#if}}, etc.
        handle_block_helper(node, context_stack)

      when Curlybars::Node::IfElse, Curlybars::Node::UnlessElse
        # Conditional blocks
        handle_conditional(node, context_stack)

      when Curlybars::Node::EachElse
        # Each loops
        handle_each(node, context_stack)

      when Curlybars::Node::WithElse
        # With blocks
        handle_with(node, context_stack)

      end
    end

    # Check if a path node matches our target when resolved against context
    def check_path_match(path_node, context_stack)
      path_segments = path_node.path.split('.')
      resolved_segments = resolve_path(path_segments, context_stack)

      if resolved_segments == @target_segments
        @matches << {
          node: path_node,
          position: path_node.position,
          resolved_path: resolved_segments.join('.'),
          context: context_stack.dup,
          line_number: path_node.position&.line_number,
          line_offset: path_node.position&.line_offset
        }
      end
    end

    # Resolve a relative path against the context stack
    def resolve_path(path_segments, context_stack)
      # If path starts with ../ it navigates up the context
      segments = path_segments.dup
      stack = context_stack.dup

      while segments.first&.start_with?('../')
        segments.shift
        stack.pop
      end

      # Combine context with remaining path segments
      stack + segments
    end

    # Handle block helpers (generic handler for {{#helper path}})
    def handle_block_helper(node, context_stack)
      # First, traverse the path used in the helper itself
      traverse(node.helper, context_stack)

      # Check if this is a context-changing helper (with, each)
      if is_context_helper?(node.helper)
        # Push the helper's path onto context and traverse the block
        new_context = context_stack + node.helper.path.split('.')
        traverse(node.helper_template, new_context)
        traverse(node.else_template, context_stack) if node.else_template
      else
        # For non-context helpers (like if, unless), don't change context
        traverse(node.helper_template, context_stack)
        traverse(node.else_template, context_stack) if node.else_template
      end

      # Traverse arguments and options
      node.arguments&.each { |arg| traverse(arg, context_stack) }
      node.options&.each { |opt| traverse(opt.expression, context_stack) }
    end

    # Handle if/unless conditionals
    def handle_conditional(node, context_stack)
      # The expression being tested
      traverse(node.expression, context_stack)

      # Both branches use the same context (no scope change)
      traverse(node.if_template, context_stack)
      traverse(node.else_template, context_stack) if node.else_template
    end

    # Handle each loops
    def handle_each(node, context_stack)
      # The path being iterated
      traverse(node.path, context_stack)

      # Inside the each block, the context is the item being iterated
      new_context = context_stack + node.path.path.split('.')
      traverse(node.each_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end

    # Handle with blocks
    def handle_with(node, context_stack)
      # The path being with'd
      traverse(node.path, context_stack)

      # Inside the with block, the context changes
      new_context = context_stack + node.path.path.split('.')
      traverse(node.with_template, new_context)
      traverse(node.else_template, context_stack) if node.else_template
    end

    # Check if a helper changes the context (with, each)
    def is_context_helper?(path_node)
      # In the actual AST, we'd need to check the helper name
      # For now, this is a simplified heuristic
      # In practice, you'd check if the block helper is 'with' or 'each'
      true # Assume block helpers change context by default
    end
  end

  # Example usage:
  if __FILE__ == $0
    require 'curlybars'

    template = <<~HBS
      {{section.name}}

      {{#each section.sections}}
        {{name}}
      {{/each}}

      {{#with section}}
        {{#each sections}}
          {{name}}
        {{/each}}
      {{/with}}
    HBS

    # Parse the template to get the AST
    ast = Curlybars::Lexer.lex(template, 'example.hbs')
    Curlybars::Processor::Tilde.process!(ast, 'example.hbs')
    parsed_ast = Curlybars::Parser.parse(ast)

    # Find all references to "section.name"
    finder = AstPathFinder.new(parsed_ast)

    puts "=" * 60
    puts "Finding: section.name"
    puts "=" * 60
    matches = finder.find("section.name")
    matches.each do |match|
      puts "Found at line #{match[:line_number]}, offset #{match[:line_offset]}"
      puts "  Resolved: #{match[:resolved_path]}"
      puts "  Context: [#{match[:context].join('.')}]"
      puts
    end

    puts "=" * 60
    puts "Finding: section.sections.name"
    puts "=" * 60
    matches = finder.find("section.sections.name")
    matches.each do |match|
      puts "Found at line #{match[:line_number]}, offset #{match[:line_offset]}"
      puts "  Resolved: #{match[:resolved_path]}"
      puts "  Context: [#{match[:context].join('.')}]"
      puts
    end
  end
end
