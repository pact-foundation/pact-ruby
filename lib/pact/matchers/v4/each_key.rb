# frozen_string_literal: true

module Pact
  module Matchers
    module V4
      class EachKey < Pact::Matchers::Base
        def initialize(key_matchers, template)
          raise MatcherInitializationError, "#{self.class}: #{template} should be a Hash" unless template.is_a?(Hash)

          unless key_matchers.is_a?(Array)
            raise MatcherInitializationError,
                  "#{self.class}: #{key_matchers} should be an Array"
          end
          unless key_matchers.all?(Pact::Matchers::Base)
            raise MatcherInitializationError,
                  "#{self.class}: #{key_matchers} should be instances of Pact::Matchers::Base"
          end
          unless key_matchers.size > 0
            raise MatcherInitializationError,
                  "#{self.class}: #{key_matchers} size should be greater than 0"
          end

          super(spec_version: Pact::Matchers::PACT_SPEC_V4, kind: 'each-key', template: template, opts: { rules: key_matchers }) # rubocop:disable Layout/LineLength
        end

        def as_plugin
          @opts[:rules].map do |matcher|
            "eachKey(#{matcher.as_plugin})"
          end.join(', ')
        end
      end
    end
  end
end
