# frozen_string_literal: true

require "rspec"
require_relative "rspec/support/pact_consumer_helpers"
require_relative "rspec/support/pact_provider_helpers"

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/pact/}) { |metadata| metadata[:pact] = true }

  # it's not an error: consumer tests contain `providers` subdirectory (because we're testing against different providers)
  config.define_derived_metadata(file_path: %r{spec/pact/providers/}) { |metadata| metadata[:pact_entity] = :consumer }
  # for provider tests it's the same thing: we're running tests which test consumers
  config.define_derived_metadata(file_path: %r{spec/pact/consumers/}) { |metadata| metadata[:pact_entity] = :provider }

  # exclude pact specs from generic rspec pipeline
  config.filter_run_excluding :pact_v2
end
