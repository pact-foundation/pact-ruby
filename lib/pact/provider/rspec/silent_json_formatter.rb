require 'rspec/core/formatters'

module Pact
  module Provider
    module RSpec
      class SilentJsonFormatter < ::RSpec::Core::Formatters::JsonFormatter

        def initialize stream
          # Don't want to display this to the screen,
          # not sure how else to set a custom stream for a particular formatter
          # Store a reference to this so it can be inspected afterwards.
          super(Pact.provider_world.json_formatter_stream)
        end

      end
    end
  end
end