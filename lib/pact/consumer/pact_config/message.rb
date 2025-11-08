# frozen_string_literal: true

require_relative 'base'

module Pact
  module Consumer
    module PactConfig
      class Message < Base
        def new_interaction(description = nil)
          MessageInteractionBuilder.new(self, description: description)
        end
      end
    end
  end
end
