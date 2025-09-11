# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V4
        class EachKeyValue < Pact::V2::Matchers::Base
          def initialize(key_matchers, template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be a Hash" unless template.is_a?(Hash)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be an Array" unless key_matchers.is_a?(Array)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be instances of Pact::V2::Matchers::Base" unless key_matchers.all?(Pact::V2::Matchers::Base)

            super(
              spec_version: Pact::V2::Matchers::PACT_SPEC_V4,
              kind: [
                EachKey.new(key_matchers, {}),
                EachValue.new([Pact::V2::Matchers::V2::Type.new("")], {})
              ],
              template: template
            )

            @key_matchers = key_matchers
          end

          def as_plugin
            raise MatcherInitializationError, "#{self.class}: each-key-value is not supported in plugin syntax. Use each / each_key / each_value matchers instead"
          end
        end
      end
    end
  end
end
