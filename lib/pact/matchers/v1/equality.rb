# frozen_string_literal: true

module Pact
  module Matchers
    module V1
      class Equality < Pact::Matchers::Base
        def initialize(template)
          super(spec_version: Pact::Matchers::PACT_SPEC_V1, kind: 'equality', template: template)
        end

        def as_plugin
          "matching(equalTo, #{format_primitive(@template)})"
        end
      end
    end
  end
end
