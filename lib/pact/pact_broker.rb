require 'pact/pact_broker/fetch_pacts'
require 'pact/pact_broker/fetch_pact_uris_for_verification'
require 'pact/provider/pact_uri'

#
# @public Used by Pact Provider Verifier
#
module Pact
  module PactBroker
    extend self

    # Keep for backwards compatibility with pact-provider-verifier < 1.23.1
    def fetch_pact_uris *args
      Pact::PactBroker::FetchPacts.call(*args).collect(&:uri)
    end

    def fetch_pact_uris_for_verification *args
      Pact::PactBroker::FetchPactURIsForVerification.call(*args)
    end

    def build_pact_uri(*args)
      Pact::Provider::PactURI.new(*args)
    end
  end
end
