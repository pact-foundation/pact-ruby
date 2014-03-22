require 'rspec/core/formatters'

module Pact
  module Provider
    module RSpec
      class SilentJsonFormatter < ::RSpec::Core::Formatters::JsonFormatter
        def initialize stream
          super(StringIO.new)
          Pact.world.json_formatter = self #Store a reference to this so it can be inspected afterwards
        end
      end
    end
  end
end