module Curlybars
  class DependencyTracker
    def self.call(path, template)
      presenter = Curlybars::Presenter.presenter_for_path(path)
      presenter.dependencies
    end
  end
end
