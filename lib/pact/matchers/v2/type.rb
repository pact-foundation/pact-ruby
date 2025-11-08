# frozen_string_literal: true

module Pact
  module Matchers
    module V2
      class Type < Pact::Matchers::Base
        def initialize(template)
          unless template.is_a?(TrueClass) || template.is_a?(FalseClass) || template.is_a?(Numeric) || template.is_a?(String) || template.is_a?(Array) || template.is_a?(Hash) # rubocop:disable Layout/LineLength
            raise MatcherInitializationError,
                  "#{self.class}: template is not a primitive"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V2, kind: 'type', template: template)
        end
      end
    end
  end
end
