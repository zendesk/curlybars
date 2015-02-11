require 'rltk/parser'
require 'curly_bars/node/root'
require 'curly_bars/node/text'
require 'curly_bars/node/if_block'
require 'curly_bars/node/path'
require 'curly_bars/node/output'
require 'curly_bars/node/with'

module CurlyBars
  class Parser < RLTK::Parser

    production(:root) do |root|
      clause('template') { |template| Node::Root.new(template).compile }
    end

    production(:template) do
      clause('items') { |items| items }
    end

    production(:items) do
      clause('items item') { |items, item| items << item }
      clause('item') { |item| [item] }
    end

    production(:item) do
      clause('TEXT') { |text| Node::Text.new(text).compile }
      clause('expression') { |expression| expression }
      clause('block_expression') { |block_expression| block_expression }
    end

    production(:expression) do
      clause('CURLYSTART .object CURLYEND') do |object|
        Node::Output.new(object).compile
      end
    end

    production(:object) do
      clause('PATH') do |path|
        Node::Path.new(path).compile
      end
    end

    production(:block_expression) do
      clause('.cond_bl_start .template cond_bl_end') do |expression, template|
        Node::IfBlock.new(expression, template).compile
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
        Node::With.new(path, template).compile
      end
    end

    production(:cond_bl_start) do
      clause('CURLYSTART IF .object CURLYEND') { |object| object }
    end

    production(:cond_bl_end) do
      clause('CURLYSTART ENDIF CURLYEND') { |_,_,_| }
    end

    production(:inv_cond_bl_start) do
      clause('CURLYSTART UNLESS .object CURLYEND') { |object| object }
    end

    production(:inv_cond_bl_end) do
      clause('CURLYSTART UNLESSCLOSE CURLYEND') { |_,_,_| }
    end

    production(:col_bl_start) do
      clause('CURLYSTART EACH .object CURLYEND') { |object| object }
    end

    production(:col_bl_end) do
      clause('CURLYSTART EACHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:with_block_start) do
      clause('CURLYSTART WITH .object CURLYEND') { |object| object }
    end

    production(:with_block_end) do
      clause('CURLYSTART WITHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:else) do
      clause('CURLYSTART ELSE CURLYEND') { |_,_,_| }
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
