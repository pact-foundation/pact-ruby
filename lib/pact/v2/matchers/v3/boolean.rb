# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Boolean < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Boolean" unless template.is_a?(TrueClass) || template.is_a?(FalseClass)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "boolean", template: template)
          end
        end
      end
    end
  end
end
