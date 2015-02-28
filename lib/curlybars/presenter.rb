require 'curlybars/method_whitelist'

module Curlybars
  class Presenter < Curly::Presenter
    extend Curlybars::MethodWhitelist
  end
end
