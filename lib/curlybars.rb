# Curlybars is a view system based on Curly that uses Handlebars syntax.
#
# Each view consists of two parts, a template and a presenter.
# The template is a valid Handlebars template.
#
#   {{#with invoice}}
#     Hello {{recipient.first_name}},
#     you owe us {{local_currency amount}}.
#   {{/with}}
#
# In the example above `recipient.first_name` is a path
# `local_currency amount` is an helper
#
# The path and helper will be converted into messages that are sent to the
# presenter, which is any Ruby object. Only public methods can be referenced.
# To continue the earlier example, here's the matching presenter:
#
#   class BankPresenter
#     def initialize(account)
#       @account = account
#     end
#
#     def invoice
#       InvoicePresenter.new(@account.owner.last_unpaid_invoice)
#     end
#
#     def recipient
#       UserPresenter.new(@account.owner)
#     end
#   end
#
#   class UserPresenter
#     def initialize(user)
#       @user = user
#     end
#
#     def first_name
#       @user.first_name
#     end
#   end
#
#   class InvoicePresenter
#     ...
#   end
#
# See Curly::Presenter for more information on presenters.
module Curlybars
  VERSION = "0.1.0"

  # Compiles a Curlybars template to Ruby code.
  #
  # template - The template String that should be compiled.
  #
  # Returns a String containing the Ruby code.
  def self.compile(template, presenter_class)
    # TODO
  end

  # Whether the Curly template is valid. This includes whether all
  # components are available on the presenter class.
  #
  # template        - The template String that should be validated.
  # presenter_class - The presenter Class.
  #
  # Returns true if the template is valid, false otherwise.
  def self.valid?(template, presenter_class)
    # TODO
  end
end

require 'curly_bars/parser'
require 'curly_bars/lexer'
require 'curly_bars/template_handler'
require 'curly_bars/railtie' if defined?(Rails)
require 'curly/presenter'
