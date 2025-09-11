# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V2
        class Regex < Pact::V2::Matchers::Base
          def initialize(regex, template)
            raise MatcherInitializationError, "#{self.class}: #{regex} should be an instance of Regexp" unless regex.is_a?(Regexp)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of String or Array" unless template.is_a?(String) || template.is_a?(Array)
            raise MatcherInitializationError, "#{self.class}: #{template} array values should be strings" if template.is_a?(Array) && !template.all?(String)

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V2, kind: "regex", template: template, opts: {regex: regex.to_s})
          end
        end
      end
    end
  end
end
