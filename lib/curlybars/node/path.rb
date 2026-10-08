module Curlybars
  module Node
    Path = Struct.new(:path, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
        rendering.path(
            #{path.inspect},
            rendering.position(#{position.line_number}, #{position.line_offset})
          )
        RUBY
      end

      def validate_as_value(branches, context: nil)
        validate(branches, check_type: :leaf, context: context)
      end

      def validate(branches, check_type: :anything, context: nil)
        resolve_and_check!(branches, check_type: check_type, context: context)
        []
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def resolve_and_check!(branches, check_type: :anything, context: nil)
        value = resolve(branches, context)

        check_type_of(branches, check_type, context)

        value
      end

      def presenter?(branches, context = nil)
        resolve(branches, context).is_a?(Hash)
      end

      def presenter_value?(value)
        value.is_a?(Hash)
      end

      def collection_value?(value)
        value.is_a?(Array) && value.first.is_a?(Hash)
      end

      def presenter_collection?(branches, context = nil)
        collection_value?(resolve(branches, context))
      end

      def leaf?(branches, context = nil)
        value = resolve(branches, context)
        value.nil?
      end

      def partial?(branches, context = nil)
        resolve(branches, context) == :partial
      end

      def helper?(branches, context = nil)
        resolve(branches, context) == :helper
      end

      def generic_helper?(branches, context = nil)
        value = resolve(branches, context)
        value.is_a?(Array) &&
          value.first == :helper &&
          presenter_value?(value.last)
      end

      def generic_collection_helper?(branches, context = nil)
        value = resolve(branches, context)
        value.is_a?(Array) &&
          value.first == :helper &&
          collection_value?(value.last)
      end

      def collectionlike?(branches, context = nil)
        presenter_collection?(branches, context) || generic_collection_helper?(branches, context)
      end

      def presenterlike?(branches, context = nil)
        presenter?(branches, context) || generic_helper?(branches, context)
      end

      def subexpression?
        false
      end

      def resolve(branches, context = nil)
        unless defined?(@value)
          tree = Curlybars.global_helpers_dependency_tree(context)
          if tree.key?(path.to_sym)
            dep_node = tree[path.to_sym]
            @value = dep_node.nil? ? :helper : [:helper, dep_node]
          end
        end

        @value ||= begin
          path_split_by_slashes = path.split('/')
          backward_steps_on_branches = path_split_by_slashes.count - 1
          base_tree_position = branches.length - backward_steps_on_branches
          base_tree_index = base_tree_position - 1

          raise Curlybars::Error::Validate.new('unallowed_path', "'#{path}' goes out of scope", position) if base_tree_index < 0

          base_tree = branches[base_tree_index]

          dotted_path_side = path_split_by_slashes.last

          offset_adjustment = 0
          dotted_path_side.split(".").map(&:to_sym).inject(base_tree) do |sub_tree, step|
            if step == :this
              next sub_tree
            elsif step == :length && sub_tree.is_a?(Array) && sub_tree.first.is_a?(Hash)
              next nil # :length is synthesised leaf
            elsif !(sub_tree.is_a?(Hash) && sub_tree.key?(step))
              message = step.to_s == path ? "'#{path}' does not exist" : "not possible to access `#{step}` in `#{path}`"
              raise Curlybars::Error::Validate.new('unallowed_path', message, position, offset_adjustment, path: path, step: step)
            end

            sub_tree[step]
          ensure
            offset_adjustment += step.length + 1 # '1' is the length of the dot
          end
        end
      end

      def cache_key
        [
          path,
          self.class.name
        ].join("/")
      end

      private

      def check_type_of(branches, check_type, context = nil)
        case check_type
        when :presenter
          return if presenter?(branches, context)

          message = "`#{path}` must resolve to a presenter"
          raise Curlybars::Error::Validate.new('not_a_presenter', message, position)
        when :presenterlike
          return if presenterlike?(branches, context)

          message = "`#{path}` must resolve to a presenter"
          raise Curlybars::Error::Validate.new('not_presenterlike', message, position)
        when :collectionlike
          return if collectionlike?(branches, context)

          message = "`#{path}` must resolve to a collection of presenters"
          raise Curlybars::Error::Validate.new('not_collectionlike', message, position)
        when :presenter_collection
          return if presenter_collection?(branches, context)

          message = "`#{path}` must resolve to a collection of presenters"
          raise Curlybars::Error::Validate.new('not_a_presenter_collection', message, position)
        when :leaf
          return if leaf?(branches, context)

          message = "`#{path}` cannot resolve to a component"
          raise Curlybars::Error::Validate.new('not_a_leaf', message, position)
        when :partial
          return if partial?(branches, context)

          message = "`#{path}` cannot resolve to a partial"
          raise Curlybars::Error::Validate.new('not_a_partial', message, position)
        when :helper
          return if helper?(branches, context)

          message = "`#{path}` cannot resolve to a helper"
          raise Curlybars::Error::Validate.new('not_a_helper', message, position)
        when :not_helper
          return unless helper?(branches, context)

          message = "`#{path}` resolves to a helper"
          raise Curlybars::Error::Validate.new('is_a_helper', message, position)
        when :anything
        else
          raise "invalid type `#{check_type}`"
        end
      end
    end
  end
end
