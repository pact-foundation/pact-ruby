# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Decimal < Pact::Matchers::Base
        def initialize(template)
          unless template.is_a?(Float)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of Float"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'decimal', template: template)
        end
      end
    end
  end
end
