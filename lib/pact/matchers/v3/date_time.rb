# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class DateTime < Pact::Matchers::Base
        def initialize(format, template)
          unless template.is_a?(String)
            raise MatcherInitializationError,
                  "#{self.class}: #{format} should be an instance of String"
          end
          unless template.is_a?(String)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of String"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'datetime', template: template, opts: { format: format }) # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
