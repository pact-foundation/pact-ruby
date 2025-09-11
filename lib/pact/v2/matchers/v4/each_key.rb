# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V4
        class EachKey < Pact::V2::Matchers::Base
          def initialize(key_matchers, template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be a Hash" unless template.is_a?(Hash)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be an Array" unless key_matchers.is_a?(Array)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be instances of Pact::V2::Matchers::Base" unless key_matchers.all?(Pact::V2::Matchers::Base)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} size should be greater than 0" unless key_matchers.size > 0

            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V4, kind: "each-key", template: template, opts: {rules: key_matchers})
          end

          def as_plugin
            @opts[:rules].map do |matcher|
              "eachKey(#{matcher.as_plugin})"
            end.join(", ")
          end
        end
      end
    end
  end
end
