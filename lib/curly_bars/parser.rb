require 'rltk/parser'
require 'curly_bars/node/root'
require 'curly_bars/node/text'
require 'curly_bars/node/if_block'
require 'curly_bars/node/path'
require 'curly_bars/node/output'
require 'curly_bars/node/with'

module CurlyBars
  class Parser < RLTK::Parser
    IncompleteBlockError = Class.new(StandardError)

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
      clause(
        'CURLYSTART .HELPER .STRING CURLYEND
          .template
        CURLYSTART .HELPERCLOSE CURLYEND') do |helper, string, template, helperclose|
        if helper != helperclose
          raise IncompleteBlockError,
            "block `#{helper}` cannot be closed by `#{helperclose}`"
        else
          #TODO Implement the hook with the presenter.
        end
      end
      clause('expression') { |expression| expression }
      clause('block_expression') { |block_expression| block_expression }
    end

    production(:expression) do
      clause('START .object END') do |object|
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
