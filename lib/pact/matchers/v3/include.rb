# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Include < Pact::Matchers::Base
        def initialize(template)
          unless template.is_a?(String)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of String"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'include', template: template)
        end
      end
    end
  end
end
