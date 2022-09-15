require 'securerandom'

module Pact
  module Provider
    module Generator
      # RandomHexadecimal provides the random hexadecimal generator which will generate a hexadecimal
      class RandomHexadecimal
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'RandomHexadecimal'
        end

        def call(hash, _params = nil, _example_value = nil)
          digits = hash['digits'] || 8
          bytes = (digits / 2).ceil
          string = SecureRandom.hex(bytes)
          string[0, digits]
        end
      end
    end
  end
end
