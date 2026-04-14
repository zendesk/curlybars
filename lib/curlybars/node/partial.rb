module Curlybars
  module Node
    Partial = Struct.new(:path, :options, :position) do
      def compile
        compiled_options = options.map do |option|
          "options.merge!(#{option.compile})"
        end.join("\n")

        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          options = ::ActiveSupport::HashWithIndifferentAccess.new
          #{compiled_options}

          partial_source = rendering.resolve_partial(#{path.path.inspect})
          if partial_source
            buffer.concat(rendering.render_partial(partial_source, #{path.path.inspect}, options).to_s)
          else
            buffer.concat(rendering.cached_call(#{path.compile}).to_s)
          end
        RUBY
      end

      def validate(branches, context: nil)
        # Validate option expressions in current scope
        errors = options.flat_map { |option| option.expression.validate(branches) }

        return errors unless context&.partial_resolver

        partial_source = begin
          context.partial_resolver.call(path.path)
        rescue StandardError
          nil
        end

        if partial_source
          if position.file_name == :"partials/#{path.path}"
            errors << Curlybars::Error::Validate.new(
              'self_referencing_partial',
              "'#{path.path}' cannot reference itself",
              position
            )
            return errors
          end

          options_tree = options.each_with_object({}) do |option, tree|
            expr = option.expression
            tree[option.key.to_sym] = if expr.respond_to?(:resolve)
              begin
                expr.resolve(branches)
              rescue Curlybars::Error::Validate
                nil
              end
            end
          end

          if context.valid?
            partial_errors = Curlybars.validate(
              options_tree,
              partial_source,
              :"partials/#{path.path}",
              validation_context: context.increment_depth,
              run_processors: false
            )
            inclusion_chain_entry = Curlybars::Position.new(
              position.file_name,
              position.line_number,
              position.line_offset,
              position.length
            )
            partial_errors.each do |e|
              e.metadata[:inclusion_chain] = (e.metadata[:inclusion_chain] || []).push(inclusion_chain_entry)
            end
            errors.concat(partial_errors)
          else
            errors << Curlybars::Error::Validate.new(
              'partial_nesting_limit_reached',
              "'#{path.path}' exceeds the partial nesting limit of #{Curlybars.configuration.partial_nesting_limit}",
              position
            )
          end
        else
          path_errors = Array(path.validate(branches, check_type: :partial))
          if path_errors.any? && context&.partial_resolver
            errors << Curlybars::Error::Validate.new(
              'partial_not_found',
              "'#{path.path}' partial could not be found",
              position
            )
          else
            errors.concat(path_errors)
          end
        end

        errors
      end

      def cache_key
        [
          path,
          options
        ].flatten.map(&:cache_key).push(position&.file_name, self.class.name).join("/")
      end
    end
  end
end
