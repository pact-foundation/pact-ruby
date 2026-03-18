# frozen_string_literal: true

module Pact
  module Generators

    def generate_random_int(min:, max:)
      Pact::Generators::RandomIntGenerator.new(min: min, max: max)
    end 
    def generate_random_decimal(digits:)
      Pact::Generators::RandomDecimalGenerator.new(digits: digits)
    end
    def generate_random_hexadecimal(digits:)
      Pact::Generators::RandomHexadecimalGenerator.new(digits: digits)
    end
    def generate_random_string(size:)
      Pact::Generators::RandomStringGenerator.new(size: size)
    end

    def generate_uuid(example: nil)
      Pact::Generators::UuidGenerator.new(example: example)
    end

    def generate_date(format: nil, example: nil)
      Pact::Generators::DateGenerator.new(format: format, example: example)
    end

    def generate_time(format: nil)
      Pact::Generators::TimeGenerator.new(format: format)
    end

    def generate_datetime(format: nil)
      Pact::Generators::DateTimeGenerator.new(format: format)
    end

    def generate_random_boolean
      Pact::Generators::RandomBooleanGenerator.new
    end

    def generate_from_provider_state(expression:, example:)
      Pact::Generators::ProviderStateGenerator.new(expression: expression, example: example).as_basic
    end

    def generate_mock_server_url(regex: nil, example: nil)
      Pact::Generators::MockServerURLGenerator.new(regex: regex, example: example)
    end
  end
end
