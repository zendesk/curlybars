require 'rltk/parser'

require 'curly_bars/node/root'
require 'curly_bars/node/template'
require 'curly_bars/node/item'
require 'curly_bars/node/text'
require 'curly_bars/node/if'
require 'curly_bars/node/if_else'
require 'curly_bars/node/unless'
require 'curly_bars/node/unless_else'
require 'curly_bars/node/each'
require 'curly_bars/node/each_else'
require 'curly_bars/node/path'
require 'curly_bars/node/string'
require 'curly_bars/node/output'
require 'curly_bars/node/with'
require 'curly_bars/node/helper'
require 'curly_bars/node/option'

module CurlyBars
  class Parser < RLTK::Parser
    start :root

    production(:root, 'template') { |template| Node::Root.new(template) }
    production(:template, 'items') { |items| Node::Template.new(items) }

    production(:items) do
      clause('items item') { |items, item| items << Node::Item.new(item) }
      clause('item') { |item| [Node::Item.new(item)] }
    end

    production(:item) do
      clause('TEXT') { |text| Node::Text.new(text) }

      clause(
        'START .HELPER .path .options? END
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
        'START UNLESS .expression END
          .template
        START ELSE END
          .template
        START UNLESSCLOSE END') do |expression, unless_template, else_template|
        Node::UnlessElse.new(expression, unless_template, else_template)
      end

      clause(
        'START EACH .path END
          .template
        START EACHCLOSE END') do |path, template|
        Node::Each.new(path, template)
      end

      clause(
        'START EACH .path END
          .template
        START ELSE END
          .template
        START EACHCLOSE END') do |path, each_template, else_template|
        Node::EachElse.new(path, each_template, else_template)
      end

      clause(
        'START WITH .path END
          .template
        START WITHCLOSE END') do |path, template|
        Node::With.new(path, template)
      end
    end

    production(:options) do
      clause('options option') { |options, option| options << option }
      clause('option') { |option| [option] }
    end
    production(:option, '.KEY .expression') do |key, expression|
      Node::Option.new(key, expression)
    end

    production(:expression) do
      clause('STRING') { |string| Node::String.new(string) }
      clause('path')  { |path| path }
    end

    production(:path, 'PATH') { |path| Node::Path.new(path) }

    finalize
  end
end
