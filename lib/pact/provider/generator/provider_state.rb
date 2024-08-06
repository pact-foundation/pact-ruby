require 'pact/logging'

module Pact
  module Provider
    module Generator
      # ProviderState provides the provider state generator which will inject
      # values provided by the provider state setup url.
      class ProviderState
        include Pact::Logging

        # rewrite of https://github.com/DiUS/pact-jvm/blob/master/core/support/src/main/kotlin/au/com/dius/pact/core/support/expressions/ExpressionParser.kt#L27
        VALUES_SEPARATOR = ','
        START_EXPRESSION = "\${"
        END_EXPRESSION = '}'

        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'ProviderState'
        end

        def call(hash, params = nil, _example_value = nil)
          params ||= {}
          parse_expression hash['expression'], params
        end

        def parse_expression(expression, params)
          return_string = []
          buffer = expression
          # initial value
          position = buffer.index(START_EXPRESSION)

          while position && position >= 0
            if position.positive?
              # add string
              return_string.push(buffer[0...position])
            end
            end_position = buffer.index(END_EXPRESSION, position)
            raise 'Missing closing brace in expression string' if !end_position || end_position.negative?

            variable = buffer[position + 2...end_position]

            if !params[variable]
              logger.info "Could not subsitute provider state key #{variable}, have #{params}"
            end

            expression = params[variable] || ''
            return_string.push(expression)

            buffer = buffer[end_position + 1...-1]
            position = buffer.index(START_EXPRESSION)
          end

          return_string.join('')
        end
      end
    end
  end
end
