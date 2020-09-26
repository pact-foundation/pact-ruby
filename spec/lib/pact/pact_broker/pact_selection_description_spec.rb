require 'pact/pact_broker/pact_selection_description'

module Pact
  module PactBroker
    describe PactSelectionDescription do
      include PactSelectionDescription

      describe "#pact_selection_description" do
        let(:provider) { "Bar" }
        let(:consumer_version_selectors) { [{ tag: "cmaster", latest: true, fallbackTag: "master"}, { tag: "prod"}] }
        let(:options) do
          {
            include_wip_pacts_since: "2020-01-01"
          }
        end
        let(:broker_base_url) { "http://broker" }

        subject { pact_selection_description(provider, consumer_version_selectors, options, broker_base_url) }

        it { is_expected.to eq "Fetching pacts for Bar from http://broker with the selection criteria: latest for tag cmaster (or master if not found), all for tag prod, work in progress pacts created after 2020-01-01" }
      end
    end
  end
end
