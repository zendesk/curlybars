require 'rltk/parser'
require 'curly_bars/node/root'
require 'curly_bars/node/template'
require 'curly_bars/node/text'
require 'curly_bars/node/if'
require 'curly_bars/node/if_else'
require 'curly_bars/node/path'
require 'curly_bars/node/output'
require 'curly_bars/node/with'
require 'curly_bars/node/helper'

module CurlyBars
  class Parser < RLTK::Parser
    start :root

    production(:root, 'template') { |template| Node::Root.new(template) }
    production(:template, 'items') { |items| Node::Template.new(items) }

    production(:items) do
      clause('items item') { |items, item| items << item }
      clause('item') { |item| [item] }
    end

    production(:item) do
      clause('TEXT') { |text| Node::Text.new(text) }

      clause(
        'START .HELPER .PATH .options? END
          .template
        START .HELPERCLOSE END') do |helper, path, options, template, helperclose|
        Node::Helper.new(helper, path, template, helperclose, options)
      end

      clause('START .expression END') do |expression|
        Node::Output.new(expression)
      end

      clause(
        'START IF .expression END
          .template
        START ENDIF END') do |expression, template|
        Node::If.new(expression, template)
      end

      clause(
        'START IF .expression END
          .template
        START ELSE END
          .template
        START ENDIF END') do |expression, if_template, else_template|
        Node::IfElse.new(expression, if_template, else_template)
      end

      clause(
        'START UNLESS .expression END
          .template
        START UNLESSCLOSE END') do |expression, template|
        Node::Unless.new(expression, template)
      end

      clause(
        'START UNLESS .object END
          .template
        START ELSE END
          .template
        START UNLESSCLOSE END') do |expression, unless_template, else_template|
        Node::UnlessElse.new(expression, unless_template, else_template)
      end

      clause(
        'START EACH .object END
          .template
        START EACHCLOSE END') do |object, template|
        Block.new(:collection, object, template)
      end

      clause(
        'START EACH .object END
          .template
        START ELSE END
          .template
        START EACHCLOSE END') do |object, template1, template2|
        Block.new(:collection, object, template1, template2)
      end

      clause(
        'START WITH .object END
          .template
        START WITHCLOSE END') do |path, template|
        Node::With.new(path, template)
      end

    end

    production(:options) do
      clause('options option') { |options, option| options.merge(option) }
      clause('option') { |option| option }
    end

    production(:option) do
      clause('.KEY .expression') { |key, expression| { key => expression } }
    end

    production(:expression) do
      clause('STRING') { |string| string }
      clause('PATH') do |path|
        Node::Path.new(path)
      end
    end

    production(:object) do
      clause('PATH') do |path|
        Node::Path.new(path)
      end
    end

    finalize

    # TODO: change me with nodes
    class Block
      attr_reader :type, :component, :nodes, :inverse_nodes

      def initialize(type, component, nodes = [], inverse_nodes = [])
        @type, @component, @nodes, @inverse_nodes = type, component, nodes, inverse_nodes

        @mode = :normal
      end

      def closed_by?(component)
        self.component.name == component.name &&
          self.component.identifier == component.identifier
      end

      def to_s
        component.to_s
      end

      def <<(node)
        if @mode == :inverse
          @inverse_nodes << node
        else
          @nodes << node
        end
      end

      def inverse!
        @mode = :inverse
      end

      def ==(other)
        other.type == type &&
          other.component == component &&
          other.nodes == nodes
      end
    end
  end
end
