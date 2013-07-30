require 'logger'
require_relative 'configuration'

module Pact
  module Logging
    def self.included(base)
      base.extend(self)
    end

    def logger
      Pact.configuration.logger
    end
  end
end