module Curlybars
  class Hbs
    def initialize(contexts, file_name)
      @contexts = contexts
      @file_name = file_name
    end

    def check_context_is_presenter(context, path, position)
      return if context.class.respond_to? :allows_method?
      message = "`#{path}` is not a context type object"
      raise Curlybars::Error::Render.new('context_is_not_a_presenter', message, position)
    end

    def check_context_is_array_of_presenters(collection, path, position)
      array_of_presenters = collection.respond_to?(:each) &&
      collection.all? { |presenter| presenter.class.respond_to? :allows_method? }
      return if array_of_presenters
      message = "`#{path}` is not an array of presenters"
      raise Curlybars::Error::Render.new('context_is_not_an_array_of_presenters', message, position)
    end

    def to_bool(condition)
      condition != false &&
      condition != [] &&
      condition != 0 &&
      condition != '' &&
      condition != nil
    end

    def path(path, position)
      chain = path.split(/\./)
      method_to_return = chain.pop

      resolved = chain.inject(contexts.last) do |context, meth|
        raise_if_not_traversable(context, meth, position)
        context.public_send(meth)
      end

      raise_if_not_traversable(resolved, method_to_return, position)
      resolved.method(method_to_return.to_sym)
    end

    def position(line_number, line_offset)
      Curlybars::Position.new(file_name, line_number, line_offset)
    end

    private

    attr_reader :contexts, :file_name

    def raise_if_not_traversable(context, meth, position)
      check_context_is_presenter(context, meth, position)
      check_context_allows_method(context, meth, position)
      check_context_has_method(context, meth, position)
    end

    def check_context_allows_method(context, meth, position)
      return if context.class.allows_method?(meth.to_sym)
      message = "`#{meth}` is not available."
      message += "Add `allow_methods :#{meth}` to #{context.class.to_s} to allow this path"
      raise Curlybars::Error::Render.new('path_not_allowed', message, position)
    end

    def check_context_has_method(context, meth, position)
      return if context.respond_to?(meth.to_sym)
      message = "`#{meth}` is not available in #{context.class.to_s}"
      raise Curlybars::Error::Render.new('path_not_allowed', message, position)
    end
  end
end
