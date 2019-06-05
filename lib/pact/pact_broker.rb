require 'pact/pact_broker/fetch_pacts'
require 'pact/pact_broker/fetch_pending_pacts'
require 'pact/pact_broker/fetch_pacts_for_verification'

#
# @public Use by Pact Provider Verifier
#
module Pact
  module PactBroker
    extend self

    def fetch_pact_uris *args
      Pact::PactBroker::FetchPacts.call(*args).collect(&:uri)
    end

    def fetch_pending_pact_uris *args
      Pact::PactBroker::FetchPendingPacts.call(*args).collect(&:uri)
    end

    def fetch_pacts_for_verification *args
      Pact::PactBroker::FetchPactsForVerification.call(*args)
    end
  end
end
