module Curlybars
  class DeprecatedBranchesRemover
    def self.perform!(branches)
      return if branches.nil?

      branches.delete_if { |_, value| value == :deprecated }

      branches.each do |key, value|
        if value.is_a? Hash
          sub_branches = value
        elsif value.is_a? Array
          sub_branches = value.first
        end

        perform!(sub_branches)
      end
    end
  end
end
