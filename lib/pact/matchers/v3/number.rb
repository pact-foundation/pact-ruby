# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Number < Pact::Matchers::Base
        def initialize(template)
          unless template.is_a?(Numeric)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of Numeric"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'number', template: template)
        end
      end
    end
  end
end
