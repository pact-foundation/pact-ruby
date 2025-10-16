# frozen_string_literal: true

module Pact
  module V2
    module Generators

      def generate_random_int(min:, max:)
        Pact::V2::Generators::RandomIntGenerator.new(min: min, max: max)
      end 
      def generate_random_decimal(digits:)
        Pact::V2::Generators::RandomDecimalGenerator.new(digits: digits)
      end
      def generate_random_hexadecimal(digits:)
        Pact::V2::Generators::RandomHexadecimalGenerator.new(digits: digits)
      end
      def generate_random_string(size:)
        Pact::V2::Generators::RandomStringGenerator.new(size: size)
      end

      def generate_uuid(example: nil)
        Pact::V2::Generators::UuidGenerator.new(example: example)
      end

      def generate_date(format: nil, example: nil)
        Pact::V2::Generators::DateGenerator.new(format: format, example: example)
      end

      def generate_time(format: nil)
        Pact::V2::Generators::TimeGenerator.new(format: format)
      end

      def generate_datetime(format: nil)
        Pact::V2::Generators::DateTimeGenerator.new(format: format)
      end

      def generate_random_boolean
        Pact::V2::Generators::RandomBooleanGenerator.new
      end

      def generate_from_provider_state(expression:)
        Pact::V2::Generators::ProviderStateGenerator.new(expression: expression)
      end

      def generate_mock_server_url(regex: nil, example: nil)
        Pact::V2::Generators::MockServerURLGenerator.new(regex: regex, example: example)
      end
    end
  end
end
