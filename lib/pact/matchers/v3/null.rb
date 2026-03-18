# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class Null < Pact::Matchers::Base
        def initialize
          super(spec_version: Pact::Matchers::PACT_SPEC_V3, kind: 'null', template: nil)
        end
      end
    end
  end
end
