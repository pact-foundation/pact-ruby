require 'pact/pact_broker/fetch_pacts'
require 'pact/pact_broker/fetch_wip_pacts'

module Pact
  module PactBroker
    extend self

    def fetch_pact_uris *args
      Pact::PactBroker::FetchPacts.call(*args).collect(&:uri)
    end

    def fetch_wip_pact_uris *args
      Pact::PactBroker::FetchWipPacts.call(*args).collect(&:uri)
    end
  end
end
