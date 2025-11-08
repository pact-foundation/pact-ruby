# frozen_string_literal: true

module Pact
  module Matchers
    module V4
      class StatusCode < Pact::Matchers::Base
        def initialize(template = nil)
          super(spec_version: Pact::Matchers::PACT_SPEC_V4, kind: 'statusCode', opts: {
            'status' => template
          })
        end
      end
    end
  end
end
