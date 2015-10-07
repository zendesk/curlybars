module Curlybars
  module Node
    Path = Struct.new(:path, :position) do
      def compile
        <<-RUBY
        rendering.path(
            #{path.inspect},
            rendering.position(#{position.line_number}, #{position.line_offset})
          )
        RUBY
      end

      def validate_as_value(branches)
        validate(branches, check_type: :leaf)
      end

      def validate(branches, check_type: :anything)
        resolve_and_check!(branches, check_type: check_type)
        []
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def resolve_and_check!(branches, check_type: :anything)
        value = resolve(branches)

        check_type_of(branches, check_type)

        value
      end

      def presenter?(branches)
        resolve(branches).is_a?(Hash)
      end

      def presenter_collection?(branches)
        value = resolve(branches)
        value.is_a?(Array) && value.first.is_a?(Hash)
      end

      def leaf?(branches)
        value = resolve(branches)
        value.nil? || value == :deprecated
      end

      def partial?(branches)
        resolve(branches) == :partial
      end

      def helper?(branches)
        resolve(branches) == :helper
      end

      def resolve(branches)
        @value ||= begin
          path_split_by_slashes = path.split('/')
          backward_steps_on_branches = path_split_by_slashes.count - 1
          base_tree_position = branches.length - backward_steps_on_branches

          throw :skip_item_validation unless base_tree_position > 0

          base_tree_index = base_tree_position - 1
          base_tree = branches[base_tree_index]

          dotted_path_side = path_split_by_slashes.last

          dotted_path_side.split(/\./).map(&:to_sym).inject(base_tree) do |sub_tree, step|
            if step == :this
              next sub_tree
            elsif step == :length && (sub_tree.is_a?(Array) && sub_tree.first.is_a?(Hash))
              next nil # :length is synthesised leaf
            elsif !(sub_tree.is_a?(Hash) && sub_tree.key?(step))
              message = "not possible to access `#{step}` in `#{path}`"
              raise Curlybars::Error::Validate.new('unallowed_path', message, position, path: path, step: step)
            end
            sub_tree[step]
          end
        end
      end

      private

      def check_type_of(branches, check_type)
        case check_type
        when :presenter
          return if presenter?(branches)
          message = "`#{path}` must resolve to a presenter"
          raise Curlybars::Error::Validate.new('not_a_presenter', message, position)
        when :presenter_collection
          return if presenter_collection?(branches)
          message = "`#{path}` must resolve to a collection of presenters"
          raise Curlybars::Error::Validate.new('not_a_presenter_collection', message, position)
        when :leaf
          return if leaf?(branches)
          message = "`#{path}` cannot resolve to a component"
          raise Curlybars::Error::Validate.new('not_a_leaf', message, position)
        when :partial
          return if partial?(branches)
          message = "`#{path}` cannot resolve to a partial"
          raise Curlybars::Error::Validate.new('not_a_partial', message, position)
        when :helper
          return if helper?(branches)
          message = "`#{path}` cannot resolve to a helper"
          raise Curlybars::Error::Validate.new('not_a_helper', message, position)
        when :anything
        else
          raise "invalid type `#{check_type}`"
        end
      end
    end
  end
end
