require 'rltk/parser'
require 'curly_bars/node/root'
require 'curly_bars/node/template'
require 'curly_bars/node/text'
require 'curly_bars/node/if_block'
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

      clause('block_expression') { |block_expression| block_expression }
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

    production(:block_expression) do
      clause('.cond_bl_start .template cond_bl_end') do |expression, template|
        Node::IfBlock.new(expression, template)
      end

      clause('.cond_bl_start .template else .template cond_bl_end') do |object, template1, template2|
        Block.new(:conditional, object, template1, template2)
      end

      clause('.inv_cond_bl_start .template inv_cond_bl_end') do |object, template|
        Block.new(:inverse_conditional, object, template)
      end

      clause('.inv_cond_bl_start .template else .template inv_cond_bl_end') do |object, template1, template2|
        Block.new(:inverse_conditional, object, template1, template2)
      end

      clause('.col_bl_start .template col_bl_end') do |object, template|
        Block.new(:collection, object, template)
      end

      clause('.col_bl_start .template else .template col_bl_end') do |object, template1, template2|
        Block.new(:collection, object, template1, template2)
      end

      clause('.with_block_start .template with_block_end') do |path, template|
        Node::With.new(path, template)
      end
    end

    production(:cond_bl_start) do
      clause('START IF .object END') { |object| object }
    end

    production(:cond_bl_end) do
      clause('START ENDIF END') { |_,_,_| }
    end

    production(:inv_cond_bl_start) do
      clause('START UNLESS .object END') { |object| object }
    end

    production(:inv_cond_bl_end) do
      clause('START UNLESSCLOSE END') { |_,_,_| }
    end

    production(:col_bl_start) do
      clause('START EACH .object END') { |object| object }
    end

    production(:col_bl_end) do
      clause('START EACHCLOSE END') { |_,_,_| }
    end

    production(:with_block_start) do
      clause('START WITH .object END') { |object| object }
    end

    production(:with_block_end) do
      clause('START WITHCLOSE END') { |_,_,_| }
    end

    production(:else) do
      clause('START ELSE END') { |_,_,_| }
    end

    finalize

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
