require 'active_support/core_ext/string/inflections'

module Curlybars
  class Visitor
    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def accept(node)
      visit(node)
      context
    end

    private

    def visit(node)
      class_name = node.class.name.to_s
      return unless class_name.start_with?('Curlybars::Node')

      method_name = class_name.demodulize.underscore
      send("visit_#{method_name}", node)
    end

    def visit_block_helper_else(node)
      node.arguments.each { |arg| visit(arg) }
      node.options.each { |opt| visit(opt) }
      visit(node.helper)
      visit(node.helper_template)
      visit(node.else_template)
    end

    def visit_boolean(_node)
    end

    def visit_each_else(node)
      visit(node.path)
      visit(node.each_template)
      visit(node.else_template)
    end

    def visit_if_else(node)
      visit(node.expression)
      visit(node.if_template)
      visit(node.else_template)
    end

    def visit_item(node)
      visit(node.item)
    end

    def visit_literal(_node)
    end

    def visit_option(node)
      visit(node.expression)
    end

    def visit_output(node)
      visit(node.value)
    end

    def visit_partial(node)
      visit(node.path)
    end

    def visit_path(_node)
    end

    def visit_root(node)
      visit(node.template)
    end

    def visit_string(_node)
    end

    def visit_template(node)
      node.items.each { |item| visit(item) }
    end

    def visit_text(_node)
    end

    def visit_unless_else(node)
      visit(node.expression)
      visit(node.unless_template)
      visit(node.else_template)
    end

    def visit_variable(_node)
    end

    def visit_with_else(node)
      visit(node.path)
      visit(node.with_template)
      visit(node.else_template)
    end
  end
end
