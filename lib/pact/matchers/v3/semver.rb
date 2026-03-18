# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Semver < Pact::Matchers::Base
        def initialize(template = nil)
          @template = template
          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'semver', template: template)
        end

        def as_plugin
          if @template.nil? || @template.blank?
            raise MatcherInitializationError, "#{self.class}: template must be provided when calling as_plugin"
          end

          "matching(semver, '#{@template}')"
        end
      end
    end
  end
end
