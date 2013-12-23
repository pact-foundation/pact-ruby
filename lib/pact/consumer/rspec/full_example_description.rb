#
# Creates the full description for an example group
#
module Pact
  module Consumer
    module RSpec
      class FullExampleDescription

        def initialize example
          @example = example
        end

        def parent_group_descriptions
          @example.example.example_group.parent_groups.collect(&:description).reverse
        end

        def example_description
          @example.example.description
        end

        def to_s
          (parent_group_descriptions + [example_description]).join(" ")
        end

      end
    end
  end
end
