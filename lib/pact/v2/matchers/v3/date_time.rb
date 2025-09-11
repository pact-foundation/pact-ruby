# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class DateTime < Pact::V2::Matchers::Base
          def initialize(format, template)
            raise MatcherInitializationError, "#{self.class}: #{format} should be an instance of String" unless template.is_a?(String)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of String" unless template.is_a?(String)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "datetime", template: template, opts: {format: format})
          end
        end
      end
    end
  end
end
