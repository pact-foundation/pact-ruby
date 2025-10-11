# frozen_string_literal: true

module Pact
  module V2
    module Matchers
      module V4
        class StatusCode < Pact::V2::Matchers::Base
          def initialize(template = nil)
            super(spec_version: Pact::V2::Matchers::PACT_SPEC_V4, kind: 'statusCode', opts: {
              'status' => template
            })
          end
        end
      end
    end
  end
end
