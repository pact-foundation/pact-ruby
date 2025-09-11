# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Each < Pact::V2::Matchers::Base
          def initialize(template, min)
            raise MatcherInitializationError, "#{self.class}: #{min} should be greater than 0" if min.present? && min < 1

            min_array_size = min.presence || 1
            val = template.is_a?(Array) ? template : [template] * min_array_size

            raise MatcherInitializationError, "#{self.class}: #{min} is invalid: template size is #{val.size}" if min_array_size != val.size

            super(
              spec_version: Pact::V2::Matchers::PACT_SPEC_V3,
              kind: "type",
              template: val,
              opts: {min: min_array_size})
          end

          def as_plugin
            if @template.first.is_a?(Hash)
              return {
                "pact:match" => "eachValue(matching($'SAMPLE'))",
                "SAMPLE" => serialize!(@template.first.deep_dup, :plugin)
              }
            end

            params = @opts.except(:min).values.map { |v| format_primitive(v) }.join(",")
            value = format_primitive(@template.first)

            return "eachValue(matching(#{@kind}, #{params}, #{value}))" if params.present?

            "eachValue(matching(#{@kind}, #{value}))"
          end
        end
      end
    end
  end
end
