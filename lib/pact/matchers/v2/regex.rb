# frozen_string_literal: true

module Pact
  module Matchers
    module V2
      class Regex < Pact::Matchers::Base
        def initialize(regex, template)
          unless regex.is_a?(Regexp)
            raise MatcherInitializationError,
                  "#{self.class}: #{regex} should be an instance of Regexp"
          end
          unless template.is_a?(String) || template.is_a?(Array)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} should be an instance of String or Array"
          end
          if template.is_a?(Array) && !template.all?(String)
            raise MatcherInitializationError,
                  "#{self.class}: #{template} array values should be strings"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V2, kind: 'regex', template: template, opts: { regex: regex.to_s }) # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
