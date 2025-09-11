# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V2
        class Type < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: template is not a primitive" unless template.is_a?(TrueClass) || template.is_a?(FalseClass) || template.is_a?(Numeric) || template.is_a?(String) || template.is_a?(Array) || template.is_a?(Hash)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V2, kind: "type", template: template)
          end
        end
      end
    end
  end
end
