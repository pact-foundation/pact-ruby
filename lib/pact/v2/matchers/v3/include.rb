# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Include < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of String" unless template.is_a?(String)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "include", template: template)
          end
        end
      end
    end
  end
end
