# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Each < Pact::Matchers::Base
        def initialize(template, min)
          if min.present? && min < 1
            raise MatcherInitializationError,
                  "#{self.class}: #{min} should be greater than 0"
          end

          min_array_size = min.presence || 1
          val = template.is_a?(Array) ? template : [template] * min_array_size

          if min_array_size != val.size
            raise MatcherInitializationError,
                  "#{self.class}: #{min} is invalid: template size is #{val.size}"
          end

          super(
            spec_version: Pact::Matchers::PACT_SPEC_V3,
            kind: 'type',
            template: val,
            opts: { min: min_array_size })
        end

        def as_plugin
          if @template.first.is_a?(Hash)
            return {
              'pact:match' => "eachValue(matching($'SAMPLE'))",
              'SAMPLE' => serialize!(@template.first.deep_dup, :plugin)
            }
          end

          params = @opts.except(:min).values.map { |v| format_primitive(v) }.join(',')
          value = format_primitive(@template.first)

          return "eachValue(matching(#{@kind}, #{params}, #{value}))" if params.present?

          "eachValue(matching(#{@kind}, #{value}))"
        end
      end
    end
  end
end
