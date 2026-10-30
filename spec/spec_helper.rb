# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"

require 'byebug'
require 'dummy/config/environment'
require 'rspec/rails'

require 'curlybars/safe_buffer'
require 'curlybars/lexer'
require 'curlybars/parser'
require 'curlybars/position'
require 'curlybars/error/base'
require 'curlybars/error/lex'
require 'curlybars/error/parse'
require 'curlybars/error/compile'
require 'curlybars/error/validate'
require 'curlybars/error/render'

RSpec.configure do |config|
  config.before do
    Curlybars.reset
  end
end
