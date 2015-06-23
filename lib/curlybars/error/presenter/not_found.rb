module Curlybars
  module Error
    module Presenter
      class NotFound < StandardError
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def message
          "error compiling `#{path}`: could not find #{presenter_class_name}"
        end

        private

        def presenter_class_name
          Curlybars::Presenter.presenter_name_for_path(path)
        end
      end
    end
  end
end
