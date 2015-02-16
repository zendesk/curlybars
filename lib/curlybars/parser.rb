require 'rltk/parser'

require 'curlybars/node/root'
require 'curlybars/node/template'
require 'curlybars/node/item'
require 'curlybars/node/text'
require 'curlybars/node/if'
require 'curlybars/node/if_else'
require 'curlybars/node/unless'
require 'curlybars/node/unless_else'
require 'curlybars/node/each'
require 'curlybars/node/each_else'
require 'curlybars/node/path'
require 'curlybars/node/string'
require 'curlybars/node/output'
require 'curlybars/node/with'
require 'curlybars/node/helper'
require 'curlybars/node/option'

module Curlybars
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
