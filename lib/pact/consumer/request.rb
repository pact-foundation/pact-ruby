require 'pact/shared/request'
require 'pact/shared/key_not_found'

module Pact
  module Consumer
    module Request
      class Actual < Pact::Request::Base

        protected

        def self.key_not_found
          Pact::KeyNotFound.new
        end       
      end      
    end
  end
end