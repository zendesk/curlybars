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
require 'curlybars/node/integer'
require 'curlybars/node/boolean'
require 'curlybars/node/with'
require 'curlybars/node/helper'
require 'curlybars/node/block_helper'
require 'curlybars/node/option'
require 'curlybars/node/partial'
require 'curlybars/node/empty'

module Curlybars
  class Parser < RLTK::Parser
    EMPTY = Curlybars::Node::Empty.new

    start :root

    production(:root, 'template?') { |template| Node::Root.new(template || EMPTY, pos(0)) }
    production(:template, 'items') { |items| Node::Template.new(items, pos(0)) }

    production(:items) do
      clause('items item') { |items, item| items << Node::Item.new(item) }
      clause('item') { |item| [Node::Item.new(item)] }
    end

    production(:item) do
      clause('TEXT') { |text| Node::Text.new(text) }

      clause(
        'START HASH .path .path .options? END
          .template?
        START SLASH .path END') do |helper, context, options, template, helperclose|
        Node::BlockHelper.new(helper, context, options, template || EMPTY, helperclose)
      end

      clause('START .path .expression? .options? END') do |path, context, options|
        Node::Helper.new(path, context, options)
      end

      clause(
        'START HASH IF .expression END
          .template?
        START SLASH IF END') do |expression, template|
        Node::If.new(expression, template || EMPTY)
      end

      clause(
        'START HASH IF .expression END
          .template?
        START ELSE END
          .template?
        START SLASH IF END') do |expression, if_template, else_template|
        Node::IfElse.new(expression, if_template || EMPTY, else_template || EMPTY)
      end

      clause(
        'START HASH UNLESS .expression END
          .template?
        START SLASH UNLESS END') do |expression, template|
        Node::Unless.new(expression, template || EMPTY)
      end

      clause(
        'START HASH UNLESS .expression END
          .template?
        START ELSE END
          .template?
        START SLASH UNLESS END') do |expression, unless_template, else_template|
        Node::UnlessElse.new(expression, unless_template || EMPTY, else_template || EMPTY)
      end

      clause(
        'START HASH EACH .path END
          .template?
        START SLASH EACH END') do |path, template|
        Node::Each.new(path, template || EMPTY, pos(0))
      end

      clause(
        'START HASH EACH .path END
          .template?
        START ELSE END
          .template?
        START SLASH EACH END') do |path, each_template, else_template|
        Node::EachElse.new(path, each_template || EMPTY, else_template || EMPTY, pos(0))
      end

      clause(
        'START HASH WITH .path END
          .template?
        START SLASH WITH END') do |path, template|
        Node::With.new(path, template || EMPTY, pos(0))
      end

      clause('START GT .path END') do |path|
        Node::Partial.new(path)
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
      clause('INTEGER') { |integer| Node::Integer.new(integer) }
      clause('BOOLEAN') { |boolean| Node::Boolean.new(boolean) }
      clause('path')  { |path| path }
    end

    production(:path, 'PATH') { |path| Node::Path.new(path, pos(0)) }

    finalize
  end
end
