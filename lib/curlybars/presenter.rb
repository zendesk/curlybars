require 'curlybars/methods_whitelisting'

module Curlybars
  class Presenter < Curly::Presenter
    include Curlybars::MethodsWhitelisting
  end
end
