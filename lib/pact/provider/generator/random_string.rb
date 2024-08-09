module Pact
  module Provider
    module Generator
      # RandomString provides the random string generator which generate a random string of size length
      class RandomString
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'RandomString'
        end

        def call(hash, _params = nil, _example_value = nil)
          size = hash['size'] || 20
          string = rand(36**(size + 2)).to_s(36)
          string[0, size]
        end
      end
    end
  end
end
