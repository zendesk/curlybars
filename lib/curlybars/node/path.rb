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

      def validate(branches, check_type: :anything)
        resolve_and_check!(branches, check_type: check_type)
        []
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def resolve_and_check!(branches, check_type: :anything)
        path_split_by_slashes = path.split('/')
        backward_steps_on_branches = path_split_by_slashes.count - 1
        base_tree_position = branches.length - backward_steps_on_branches

        throw :skip_item_validation unless base_tree_position > 0

        base_tree_index = base_tree_position - 1
        base_tree = branches[base_tree_index]

        dotted_path_side = path_split_by_slashes.last

        value = dotted_path_side.split(/\./).map(&:to_sym).inject(base_tree) do |sub_tree, step|
          if step == :this
            next sub_tree
          elsif !(sub_tree.is_a?(Hash) && sub_tree.key?(step))
            message = "not possible to access `#{step}` in `#{path}`"
            raise Curlybars::Error::Validate.new('unallowed_path', message, position, path: path, step: step)
          end
          sub_tree[step]
        end

        check_type_of(check_type, value)

        value
      end

      private

      def check_type_of(check_type, value)
        case check_type
        when :presenter
          return if value.is_a?(Hash)
          message = "`#{path}` must resolve to a presenter"
          raise Curlybars::Error::Validate.new('not_a_presenter', message, position)
        when :presenter_collection
          return if value.is_a?(Array) && value.first.is_a?(Hash)
          message = "`#{path}` must resolve to a collection of presenters"
          raise Curlybars::Error::Validate.new('not_a_presenter_collection', message, position)
        when :leaf
          return if value.nil? || value == :deprecated
          message = "`#{path}` cannot resolve to a presenter or a collection of such"
          raise Curlybars::Error::Validate.new('not_a_leaf', message, position)
        when :partial
          return if value == :partial
          message = "`#{path}` cannot resolve to a partial"
          raise Curlybars::Error::Validate.new('not_a_partial', message, position)
        when :anything
        else
          raise "invalid type `#{check_type}`"
        end
      end
    end
  end
end
