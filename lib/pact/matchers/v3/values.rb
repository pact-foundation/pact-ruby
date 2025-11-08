# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Values < Pact::Matchers::Base
        def initialize
          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'values', template: nil)
        end
      end
    end
  end
end
