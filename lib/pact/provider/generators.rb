require 'pact/provider/generator/boolean'
require 'pact/provider/generator/date'
require 'pact/provider/generator/datetime'
require 'pact/provider/generator/provider_state'
require 'pact/provider/generator/random_decimal'
require 'pact/provider/generator/random_hexadecimal'
require 'pact/provider/generator/random_int'
require 'pact/provider/generator/random_string'
require 'pact/provider/generator/regex'
require 'pact/provider/generator/time'
require 'pact/provider/generator/uuid'
require 'pact/matching_rules/jsonpath'
require 'pact/matching_rules/v3/extract'
require 'jsonpath'

module Pact
  module Provider
    class Generators
      def self.add_generator(generator)
        generators.unshift(generator)
      end

    def self.generators
        @generators ||= []
      end

      def self.execute_generators(object, state_params = nil, example_value = nil)
        generators.each do |parser|
          return parser.call(object, state_params, example_value) if parser.can_generate?(object)
        end

        raise Pact::UnrecognizePactFormatError, "This document does not use a recognised Pact generator: #{object}"
      end

      def self.apply_generators(expected_request, component, example_value, state_params)
        # Latest pact-support is required to have generators exposed
        if expected_request.methods.include?(:generators) && expected_request.generators[component]
          # Some component will have single generator without selectors, i.e. path
          generators = expected_request.generators[component]
          if generators.is_a?(Hash) && generators.key?('type')
            return execute_generators(generators, state_params, example_value)
          end

          generators.each do |selector, generator|
            val = JsonPath.new(selector).on(example_value)
            replace = execute_generators(generator, state_params, val)
            example_value = JsonPath.for(example_value).gsub(selector) { |_v| replace }.to_hash
          end
        end
        example_value
      end

      add_generator(Generator::Boolean.new)
      add_generator(Generator::Date.new)
      add_generator(Generator::DateTime.new)
      add_generator(Generator::ProviderState.new)
      add_generator(Generator::RandomDecimal.new)
      add_generator(Generator::RandomHexadecimal.new)
      add_generator(Generator::RandomInt.new)
      add_generator(Generator::RandomString.new)
      add_generator(Generator::Regex.new)
      add_generator(Generator::Time.new)
      add_generator(Generator::Uuid.new)
    end
  end
end
