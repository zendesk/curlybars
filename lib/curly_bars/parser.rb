require 'rltk/parser'
require 'curly_bars/node/root'
require 'curly_bars/node/text'
require 'curly_bars/node/if_block'
require 'curly_bars/node/path'
require 'curly_bars/node/output'

module CurlyBars
  class Parser < RLTK::Parser

    production(:root) do |root|
      clause('template') { |template| Node::Root.new(template).compile }
    end

    production(:template) do
      clause('template_items') { |i| i }
    end

    production(:template_items) do
      clause('template_items template_item') { |i0,i1| i0 << i1 }
      clause('template_item') { |i| [i] }
    end

    production(:template_item) do
      clause('output') { |e| e }
      clause('expression') { |e| e }
      clause('block_expression') { |e| e }
    end

    production(:output) do
      clause('OUT') { |o| Node::Text.new(o).compile }
    end

    production(:expression) do
      clause('CURLYSTART .object CURLYEND') do |object|
        Node::Output.new(object).compile
      end
    end

    production(:object) do
      clause('IDENT') do |e|
        Node::Path.new(e).compile
      end
    end

    production(:block_expression) do
      clause('cond_bl_start template cond_bl_end') do |expression, template, _|
        Node::IfBlock.new(expression, template).compile
      end

      clause('cond_bl_start template else template cond_bl_end') { |e0, e1, _, e2, _| Block.new(:conditional, e0, e1, e2) }

      clause('inv_cond_bl_start template inv_cond_bl_end') { |e0, e1, _| Block.new(:inverse_conditional, e0, e1) }
      clause('inv_cond_bl_start template else template inv_cond_bl_end') { |e0, e1, _, e2, _| Block.new(:inverse_conditional, e0, e1, e2) }

      clause('col_bl_start template col_bl_end') { |e0, e1, _| Block.new(:collection, e0, e1) }
      clause('col_bl_start template else template col_bl_end') { |e0, e1, _, e2, _| Block.new(:collection, e0, e1, e2) }

      clause('context_bl_start template context_bl_end') { |e0, e1, _| Block.new(:context, e0, e1) }
    end

    production(:cond_bl_start) do
      clause('CURLYSTART IF object CURLYEND') { |_,_,e,_| e }
    end

    production(:cond_bl_end) do
      clause('CURLYSTART ENDIF CURLYEND') { |_,_,_| }
    end

    production(:inv_cond_bl_start) do
      clause('CURLYSTART UNLESS object CURLYEND') { |_,_,e,_| e }
    end

    production(:inv_cond_bl_end) do
      clause('CURLYSTART UNLESSCLOSE CURLYEND') { |_,_,_| }
    end

    production(:col_bl_start) do
      clause('CURLYSTART EACH object CURLYEND') { |_,_,e,_| e }
    end

    production(:col_bl_end) do
      clause('CURLYSTART EACHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:context_bl_start) do
      clause('CURLYSTART WITH object CURLYEND') { |_,_,e,_| e }
    end

    production(:context_bl_end) do
      clause('CURLYSTART WITHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:else) do
      clause('CURLYSTART ELSE CURLYEND') { |_,_,_| }
    end

    finalize

    class Component
      attr_reader :name, :identifier, :attributes

      def initialize(name, identifier = nil, attributes = {})
        @name, @identifier, @attributes = name, identifier, attributes
      end

      def to_s
        [name, identifier].compact.join(".")
      end

      def ==(other)
        other.name == name &&
          other.identifier == identifier &&
          other.attributes == attributes
      end

      def type
        :component
      end
    end

    class Comment
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def type
        :comment
      end

      def ==(other)
        other.value == value
      end
    end

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
