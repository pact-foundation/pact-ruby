# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Boolean < Pact::Matchers::Base
        def initialize(template)
          unless template.is_a?(TrueClass) || template.is_a?(FalseClass)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of Boolean"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'boolean', template: template)
        end
      end
    end
  end
end
