# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Number < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Numeric" unless template.is_a?(Numeric)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "number", template: template)
          end
        end
      end
    end
  end
end
