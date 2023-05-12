require 'string_pattern'

module Pact
  module Provider
    module Generator
      # Regex provides the regex generator which will generate a value based on the regex pattern provided
      class Regex
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'Regex'
        end

        def call(hash, _params = nil, _example_value = nil)
          pattern = hash['pattern'] || ''
          StringPattern.generate(Regexp.new(pattern))
        end
      end
    end
  end
end
