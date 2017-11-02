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
