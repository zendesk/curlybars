require 'curlybars/method_whitelist'

module Curlybars
  class Presenter < Curly::Presenter
    extend Curlybars::MethodWhitelist

    def self.presenter_for_path(path)
      name_space = Curlybars.configuration.presenters_namespace
      super(File.join(name_space, path))
    end
  end
end
