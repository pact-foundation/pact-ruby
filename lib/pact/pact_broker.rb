require 'pact/pact_broker/fetch_pacts'
require 'pact/pact_broker/fetch_pact_uris_for_verification'
require 'pact/provider/pact_uri'

#
# @public Used by Pact Provider Verifier
#
module Pact
  module PactBroker
    extend self

    def fetch_pact_uris_for_verification *args
      Pact::PactBroker::FetchPactURIsForVerification.call(*args)
    end

    def build_pact_uri(*args)
      Pact::Provider::PactURI.new(*args)
    end
  end
end
