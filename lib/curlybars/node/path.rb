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

      def validate(base_tree, check_type: :anything)
        resolve_and_check!(base_tree, check_type: check_type)
        []
      rescue Curlybars::Error::Validate => path_error
        path_error
      end

      def resolve_and_check!(base_tree, check_type: :anything)
        value = path.split(/\./).map(&:to_sym).inject(base_tree) do |sub_tree, step|
          if !sub_tree.is_a?(Hash)
            message = "not possible to access `#{step}` in `#{path}`"
            raise Curlybars::Error::Validate.new('cannot_access_presenter', message, position)
          elsif !sub_tree.key?(step)
            message = "`#{step}` is not an allowed subpath"
            raise Curlybars::Error::Validate.new('unallowed_path', message, position)
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
          return if value.nil?
          message = "`#{path}` cannot resolve to a presenter or a collection of such"
          raise Curlybars::Error::Validate.new('not_a_leaf', message, position)
        when :anything
        else
          raise "invalid type `#{check_type}`"
        end
      end
    end
  end
end
