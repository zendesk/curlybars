module Curlybars
  class RenderingSupport
    def initialize(contexts, variables, file_name, global_helpers_providers = [])
      @contexts = contexts
      @variables = variables
      @file_name = file_name
      @cached_calls = {}

      @global_helpers = {}

      global_helpers_providers.each do |provider|
        provider.allowed_methods.each do |global_helper_name|
          symbol = global_helper_name.to_sym
          @global_helpers[symbol] = provider.method(symbol)
        end
      end
    end

    def check_context_is_presenter(context, path, position)
      return if presenter?(context)
      message = "`#{path}` is not a context type object"
      raise Curlybars::Error::Render.new('context_is_not_a_presenter', message, position)
    end

    def check_context_is_hash_or_enum_of_presenters(collection, path, position)
      return if presenter_collection?(collection)

      message = "`#{path}` is not an array of presenters or a hash of such"
      raise Curlybars::Error::Render.new('context_is_not_an_array_of_presenters', message, position)
    end

    def to_bool(condition)
      condition != false &&
        condition != [] &&
        condition != {} &&
        condition != 0 &&
        condition != '' &&
        !condition.nil?
    end

    def variable(variable_path, position)
      check_traverse_not_too_deep(variable_path, position)

      variable_split_by_slashes = variable_path.split('/')
      variable = variable_split_by_slashes.last.to_sym
      backward_steps_on_variables = variable_split_by_slashes.count - 1
      variables_position = variables.length - backward_steps_on_variables
      scope = variables.first(variables_position).reverse.find do |vars|
        vars.key? variable
      end
      return scope[variable] if scope
    end

    def path(path, position)
      return global_helpers[path.to_sym] if global_helpers.key?(path.to_sym)

      check_traverse_not_too_deep(path, position)

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
        next context if meth == 'this'
        next context.count if meth == 'length' && presenter_collection?(context)
        raise_if_not_traversable(context, meth, position)
        outcome = context.public_send(meth)
        return -> {} if outcome.nil?
        outcome
      end

      return -> { resolved } if method_to_return == 'this'

      if method_to_return == 'length' && presenter_collection?(resolved)
        return -> { resolved.count }
      end

      raise_if_not_traversable(resolved, method_to_return, position)
      resolved.method(method_to_return.to_sym)
    end

    def cached_call(meth)
      return cached_calls[meth] if cached_calls.key? meth
      cached_calls[meth] = meth.call
    end

    def call(helper, helper_path, helper_position, arguments, options, &block)
      parameters = helper.parameters

      has_invalid_parameters = parameters.map(&:first).map { |type| type != :req }.any?
      if has_invalid_parameters
        file_path = helper.source_location.first
        line_number = helper.source_location.last

        message = "#{file_path}:#{line_number} - `#{helper_path}` bad signature "
        message << "for #{helper} - helpers must have only required parameters"
        raise Curlybars::Error::Render.new('invalid_helper_signature', message, helper_position)
      end

      helper.call(*arguments_for_signature(helper, arguments, options), &block)
    end

    def position(line_number, line_offset)
      Curlybars::Position.new(file_name, line_number, line_offset)
    end

    def coerce_to_hash!(collection, path, position)
      check_context_is_hash_or_enum_of_presenters(collection, path, position)
      if collection.is_a?(Hash)
        collection
      elsif collection.respond_to? :each_with_index
        collection.each_with_index.map { |value, index| [index, value] }.to_h
      else
        raise "Collection is not coerceable to hash"
      end
    end

    def presenter?(context)
      context.respond_to? :allows_method?
    end

    def presenter_collection?(collection)
      collection = collection.values if collection.is_a?(Hash)

      collection.respond_to?(:each) && collection.all? do |presenter|
        presenter?(presenter)
      end
    end

    private

    attr_reader :contexts, :variables, :cached_calls, :file_name, :global_helpers

    def arguments_for_signature(helper, arguments, options)
      return [] if helper.parameters.length == 0

      number_of_parameters_available_for_arguments = helper.parameters.length - 1
      arguments_that_can_fit = arguments.first(number_of_parameters_available_for_arguments)
      nil_padding_length = number_of_parameters_available_for_arguments - arguments_that_can_fit.length
      nil_padding = Array.new(nil_padding_length)

      [arguments_that_can_fit, nil_padding, options].flatten(1)
    end

    def raise_if_not_traversable(context, meth, position)
      check_context_is_presenter(context, meth, position)
      check_context_allows_method(context, meth, position)
      check_context_has_method(context, meth, position)
    end

    def check_context_allows_method(context, meth, position)
      return if context.allows_method?(meth.to_sym)
      message = "`#{meth}` is not available - "
      message += "add `allow_methods :#{meth}` to #{context.class} to allow this path"
      raise Curlybars::Error::Render.new('unallowed_path', message, position, meth: meth.to_sym)
    end

    def check_context_has_method(context, meth, position)
      return if context.respond_to?(meth.to_sym)
      message = "`#{meth}` is not available in #{context.class}"
      raise Curlybars::Error::Render.new('unallowed_path', message, position)
    end

    def check_traverse_not_too_deep(traverse, position)
      return unless traverse.count('.') > Curlybars.configuration.traversing_limit
      message = "`#{traverse}` too deep"
      raise Curlybars::Error::Render.new('traverse_too_deep', message, position)
    end
  end
end
