# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V4
        class NotEmpty < Pact::V2::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should not be empty" if template.blank?

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V4, kind: "time", template: template)
          end
        end
      end
    end
  end
end
