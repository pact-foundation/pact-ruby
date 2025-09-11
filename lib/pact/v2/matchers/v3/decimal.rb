# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Decimal < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Float" unless template.is_a?(Float)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "decimal", template: template)
          end
        end
      end
    end
  end
end
