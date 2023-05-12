require 'securerandom'

module Pact
  module Provider
    module Generator
      # Uuid provides the uuid generator
      class Uuid
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'Uuid'
        end

        # If we had the example value, we could determine what type of uuid
        # to send, this is what pact-jvm does
        # See https://github.com/pact-foundation/pact-jvm/blob/master/core/model/src/main/kotlin/au/com/dius/pact/core/model/generators/Generator.kt
        def call(_hash, _params = nil, _example_value = nil)
          SecureRandom.uuid
        end
      end
    end
  end
end
