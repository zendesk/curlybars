module Curlybars
  class RenderingSupport
    def initialize(contexts, file_name)
      @contexts = contexts
      @file_name = file_name
    end

    def check_context_is_presenter(context, path, position)
      return if context.respond_to?(:allows_method?)
      message = "`#{path}` is not a context type object"
      raise Curlybars::Error::Render.new('context_is_not_a_presenter', message, position)
    end

    def check_context_is_array_of_presenters(collection, path, position)
      return if collection.respond_to?(:each) && collection.all? do |presenter|
        presenter.respond_to? :allows_method?
      end

      message = "`#{path}` is not an array of presenters"
      raise Curlybars::Error::Render.new('context_is_not_an_array_of_presenters', message, position)
    end

    def to_bool(condition)
      condition != false &&
        condition != [] &&
        condition != 0 &&
        condition != '' &&
        !condition.nil?
    end

    def path(path, position)
      path_split_by_slashes = path.split('/')
      backward_steps_on_contexts = path_split_by_slashes.count - 1
      base_context_position = contexts.length - backward_steps_on_contexts

      return -> {} unless base_context_position > 0

      base_context_index = base_context_position - 1
      base_context = contexts[base_context_index]

      dotted_path_side = path_split_by_slashes.last
      chain = dotted_path_side.split('.')
      method_to_return = chain.pop

      resolved = chain.inject(base_context) do |context, meth|
        raise_if_not_traversable(context, meth, position)
        outcome = context.public_send(meth)
        return -> {} if outcome.nil?
        outcome
      end

      raise_if_not_traversable(resolved, method_to_return, position)
      resolved.method(method_to_return.to_sym)
    end

    def call(helper, helper_path, helper_position, context, options, &block)
      parameters = helper.parameters

      has_invalid_parameters = parameters.map(&:first).map { |type| type != :req }.any?
      if parameters.length > 2 || has_invalid_parameters
        file_path = helper.source_location.first
        line_number = helper.source_location.last

        message = "#{file_path}:#{line_number} - `#{helper_path}` bad signature "
        message << "for #{helper} - helpers must have at most two parameters "
        message << ", and they have to be mandatory"
        raise Curlybars::Error::Render.new('invalid_helper_signature', message, helper_position)
      end

      arguments = [context, options].first(parameters.length)
      helper.call(*arguments, &block)
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
      return if context.allows_method?(meth.to_sym)
      message = "`#{meth}` is not available - "
      message += "add `allow_methods :#{meth}` to #{context.class} to allow this path"
      raise Curlybars::Error::Render.new('path_not_allowed', message, position)
    end

    def check_context_has_method(context, meth, position)
      return if context.respond_to?(meth.to_sym)
      message = "`#{meth}` is not available in #{context.class}"
      raise Curlybars::Error::Render.new('path_not_allowed', message, position)
    end
  end
end
