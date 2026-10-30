# frozen_string_literal: true

require 'curlybars/token'

require 'curlybars/node/root'
require 'curlybars/node/template'
require 'curlybars/node/item'
require 'curlybars/node/text'
require 'curlybars/node/if_else'
require 'curlybars/node/unless_else'
require 'curlybars/node/each_else'
require 'curlybars/node/path'
require 'curlybars/node/literal'
require 'curlybars/node/variable'
require 'curlybars/node/with_else'
require 'curlybars/node/block_helper_else'
require 'curlybars/node/option'
require 'curlybars/node/partial'
require 'curlybars/node/output'
require 'curlybars/node/sub_expression'

module Curlybars
  # Recursive descent parser turning a token stream from Curlybars::Lexer into
  # an AST of Curlybars::Node objects.
  #
  # Grammar (tokens in upper case, `?` optional, `*` zero or more):
  #
  #   root          := template? EOS
  #   template      := item+
  #   item          := TEXT
  #                  | START HASH block
  #                  | START GT path option* END
  #                  | START path expression* option* END
  #                  | START value END
  #   block         := (IF | UNLESS) expression END body(IF | UNLESS)
  #                  | (EACH | WITH) (path | subexpression) END body(EACH | WITH)
  #                  | path expression* option* END body(path)
  #   body(close)   := template? (START ELSE END template?)? START SLASH close END
  #   option        := KEY expression
  #   expression    := value | path | subexpression
  #   value         := LITERAL | VARIABLE
  #   path          := PATH
  #   subexpression := LPAREN path expression* option* RPAREN
  #
  # Inside a block body, a template ends at `{{/` or `{{else`, which is why the
  # parser looks one token past START before deciding to parse an item.
  class Parser
    class Error < StandardError
      # The token that the parser could not accept.
      attr_reader :current

      def initialize(current)
        @current = current
        super("Unexpected token #{current.type}")
      end
    end

    class ParseDepthExceeded < Error
      # The depth limit that the template exceeded.
      attr_reader :limit

      def initialize(current, limit)
        @limit = limit
        super(current)
      end
    end

    # Blocks and subexpressions nested deeper than the depth limit are rejected,
    # so that recursion in the parser, in Node#validate and Node#compile, and in
    # Ruby compiling the generated code cannot exhaust the stack. The last one
    # is the tightest, and it is bounded by the machine stack rather than the VM
    # stack: with a 1 MB machine stack, about 72 nested #each blocks are enough
    # to raise SystemStackError, and each extra MB allows roughly 70 more
    # levels. Threads get 1 MB by default (RUBY_THREAD_MACHINE_STACK_SIZE),
    # while the main thread gets the process stack size limit (`ulimit -s`).
    DEFAULT_PARSE_DEPTH_LIMIT = 50

    EXPRESSION_START = [:LITERAL, :VARIABLE, :PATH, :LPAREN].freeze

    def self.parse(tokens, depth_limit: DEFAULT_PARSE_DEPTH_LIMIT)
      new(tokens, depth_limit: depth_limit).parse
    end

    attr_reader :depth_limit

    # The deepest nesting of blocks and subexpressions seen so far, which is
    # what the depth limit applies to.
    attr_reader :max_depth

    def initialize(tokens, depth_limit: DEFAULT_PARSE_DEPTH_LIMIT)
      @tokens = tokens
      @depth_limit = depth_limit
      @index = 0
      @depth = 0
      @max_depth = 0
    end

    def parse
      template = parse_template(in_block: false)
      expect(:EOS)
      if template
        Node::Root.new(template, template.position)
      else
        Node::Root.new(VOID, StreamPosition::NULL)
      end
    end

    private

    def parse_template(in_block:)
      first_index = @index
      items = []
      items << Node::Item.new(parse_item) while item_start?(in_block)
      Node::Template.new(items, span(first_index)) unless items.empty?
    end

    def item_start?(in_block)
      case peek.type
      when :TEXT then true
      when :START then !(in_block && [:SLASH, :ELSE].include?(peek(1).type))
      else false
      end
    end

    def parse_item
      return Node::Text.new(advance.value) if peek.type == :TEXT

      first_index = @index
      expect(:START)

      case peek.type
      when :HASH
        advance
        parse_block(first_index)
      when :GT
        advance
        path = parse_path
        options = parse_options
        expect(:END)
        Node::Partial.new(path, options, span(first_index))
      when :PATH
        helper = parse_path
        arguments = parse_expressions
        options = parse_options
        expect(:END)
        Node::BlockHelperElse.new(helper, arguments, options, VOID, VOID, helper, span(first_index))
      when :LITERAL
        literal = parse_literal
        expect(:END)
        Node::Output.new(literal)
      when :VARIABLE
        variable = parse_variable
        expect(:END)
        Node::Output.new(variable)
      else
        raise Error, peek
      end
    end

    def parse_block(first_index)
      case peek.type
      when :IF, :UNLESS
        keyword = advance.type
        expression = parse_expression
        expect(:END)
        template, else_template = parse_body(first_index) { expect(keyword) }
        node_class = keyword == :IF ? Node::IfElse : Node::UnlessElse
        node_class.new(expression, template || VOID, else_template || VOID)
      when :EACH, :WITH
        keyword = advance.type
        path = peek.type == :LPAREN ? parse_subexpression : parse_path
        expect(:END)
        template, else_template = parse_body(first_index) { expect(keyword) }
        node_class = keyword == :EACH ? Node::EachElse : Node::WithElse
        node_class.new(path, template || VOID, else_template || VOID, span(first_index))
      when :PATH
        helper = parse_path
        arguments = parse_expressions
        options = parse_options
        expect(:END)
        template, else_template, helperclose = parse_body(first_index) { parse_path }
        Node::BlockHelperElse.new(
          helper,
          arguments,
          options,
          template || VOID,
          else_template || VOID,
          helperclose,
          span(first_index)
        )
      else
        raise Error, peek
      end
    end

    # Parses a block body up to and including its closing tag. The block
    # parses the name that follows `{{/`, which is returned as the third
    # element.
    def parse_body(first_index)
      nested(first_index) do
        template = parse_template(in_block: true)
        expect(:START)

        if peek.type == :ELSE
          advance
          expect(:END)
          else_template = parse_template(in_block: true)
          expect(:START)
        end

        expect(:SLASH)
        closing_name = yield
        expect(:END)

        [template, else_template, closing_name]
      end
    end

    def parse_options
      options = []
      options << Node::Option.new(advance.value, parse_expression) while peek.type == :KEY
      options
    end

    def parse_expressions
      expressions = []
      expressions << parse_expression while EXPRESSION_START.include?(peek.type)
      expressions
    end

    def parse_expression
      case peek.type
      when :LITERAL then parse_literal
      when :VARIABLE then parse_variable
      when :PATH then parse_path
      when :LPAREN then parse_subexpression
      else raise Error, peek
      end
    end

    def parse_literal
      token = expect(:LITERAL)
      Node::Literal.new(token.value)
    end

    def parse_variable
      token = expect(:VARIABLE)
      Node::Variable.new(token.value, token.position)
    end

    def parse_path
      token = expect(:PATH)
      Node::Path.new(token.value, token.position)
    end

    def parse_subexpression
      first_index = @index
      expect(:LPAREN)
      nested(first_index) do
        helper = parse_path
        arguments = parse_expressions
        options = parse_options
        expect(:RPAREN)
        Node::SubExpression.new(helper, arguments, options, span(first_index))
      end
    end

    def nested(first_index)
      raise ParseDepthExceeded.new(@tokens[first_index], depth_limit) if @depth >= depth_limit

      @depth += 1
      @max_depth = @depth if @depth > @max_depth
      result = yield
      @depth -= 1
      result
    end

    # The position spanning from the token at `first_index` through the last
    # token consumed.
    def span(first_index)
      start = @tokens[first_index].position
      finish = @tokens[@index - 1].position
      StreamPosition.new(
        start.stream_offset,
        start.line_number,
        start.line_offset,
        finish.stream_offset + finish.length - start.stream_offset,
        start.file_name
      )
    end

    def expect(type)
      raise Error, peek unless peek.type == type

      advance
    end

    def advance
      token = peek
      @index += 1
      token
    end

    def peek(offset = 0)
      @tokens[@index + offset] || Token::EOS
    end

    VOID = Class.new do
      def compile
        # Nothing to compile.
      end

      def validate(branches, context: nil)
        [] # Nothing to validate.
      end

      def cache_key
        # Empty cache key.
      end
    end.new
    private_constant :VOID
  end
end
