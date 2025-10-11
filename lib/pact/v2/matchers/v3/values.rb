# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V3
        class Values < Pact::V2::Matchers::Base
          def initialize
            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V3, kind: "values", template: nil)
          end

        end
      end
    end
  end
end
