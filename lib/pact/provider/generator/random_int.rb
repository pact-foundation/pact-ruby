module Pact
  module Provider
    module Generator
      # RandomInt provides the random int generator which generate a random integer, with a min/max
      class RandomInt
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'RandomInt'
        end

        def call(hash, _params = nil, _example_value = nil)
          min = hash['min'] || 0
          max = hash['max'] || 2_147_483_647
          rand(min..max)
        end
      end
    end
  end
end
