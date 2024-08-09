require 'bigdecimal'

module Pact
  module Provider
    module Generator
      # RandomDecimal provides the random decimal generator which will generate a decimal value of digits length
      class RandomDecimal
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == 'RandomDecimal'
        end

        def call(hash, _params = nil, _example_value = nil)
          digits = hash['digits'] || 6

          raise 'RandomDecimalGenerator digits must be > 0, got $digits' if digits < 1

          return rand(0..9) if digits == 1

          return rand(0..9) + rand(1..9) / 10 if digits == 2

          pos = rand(1..digits - 1)
          precision = digits - pos
          integers = ''
          decimals = ''
          while pos.positive?
            integers += String(rand(1..9))
            pos -= 1
          end
          while precision.positive?
            decimals += String(rand(1..9))
            precision -= 1
          end

          Float("#{integers}.#{decimals}")
        end
      end
    end
  end
end
