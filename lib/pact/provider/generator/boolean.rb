module Pact
  module Provider
    module Generator
      # Boolean provides the boolean generator which will give a true or false value
      class Boolean
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'Boolean'
        end

        def call(_hash, _params = nil, _example_value = nil)
          [true, false].sample
        end
      end
    end
  end
end
