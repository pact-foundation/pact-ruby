require 'pact/pact_broker/pact_selection_description'

module Pact
  module PactBroker
    describe PactSelectionDescription do
      include PactSelectionDescription

      describe "#pact_selection_description" do
        let(:provider) { "Bar" }
        let(:consumer_version_selectors) { [{ tag: "cmaster", latest: true, fallbackTag: "master" }, { tag: "prod" }] }
        let(:options) do
          {
            include_wip_pacts_since: "2020-01-01"
          }
        end
        let(:broker_base_url) { "http://broker" }

        subject { pact_selection_description(provider, consumer_version_selectors, options, broker_base_url) }

        it { is_expected.to eq "Fetching pacts for Bar from http://broker with the selection criteria: latest for tag cmaster (or master if not found), all for tag prod, work in progress pacts created after 2020-01-01" }

        describe "when consumer selector specifies a consumer name" do
          let(:consumer_version_selectors) { [{ tag: "cmaster", latest: true, consumer: "Foo" }] }

          it { is_expected.to eq "Fetching pacts for Bar from http://broker with the selection criteria: latest for tag cmaster of Foo, work in progress pacts created after 2020-01-01" }
        end

        describe "for branch" do
          let(:consumer_version_selectors) { [{ branch: "feat/x", consumer: "Foo" }] }

          it { is_expected.to include "latest from branch feat/x of Foo" }
        end

        describe "for main branch" do
          let(:consumer_version_selectors) { [{ mainBranch: true, consumer: "Foo" }] }

          it { is_expected.to include "latest from main branch of Foo" }
        end

        describe "for deployedOrReleased" do
          let(:consumer_version_selectors) { [{ deployedOrReleased: true }] }

          it { is_expected.to include "currently deployed or released" }
        end

        describe "for released in environment" do
          let(:consumer_version_selectors) { [{ released: true, environment: "production" }] }

          it { is_expected.to include "currently released to production" }
        end

        describe "for deployed in environment" do
          let(:consumer_version_selectors) { [{ deployed: true, environment: "production" }] }

          it { is_expected.to include "currently deployed to production" }
        end

        describe "for deployedOrReleased in environment" do
          let(:consumer_version_selectors) { [{ deployedOrReleased: true, environment: "production" }] }

          it { is_expected.to include "currently deployed or released to production" }
        end

        describe "in environment" do
          let(:consumer_version_selectors) { [{ environment: "production" }] }

          it { is_expected.to include "in production" }
        end

        describe "matching branch" do
          let(:consumer_version_selectors) { [{ matchingBranch: true, consumer: "Foo" }] }

          it { is_expected.to include "matching current branch for Foo" }
        end

        describe "matching tag" do
          let(:consumer_version_selectors) { [{ matchingTag: true, consumer: "Foo" }] }

          it { is_expected.to include "matching tag for Foo" }
        end

        describe "unknown" do
          let(:consumer_version_selectors) { [{ branchPattern: "*foo" }] }

          it { is_expected.to include "branchPattern" }
          it { is_expected.to include "*foo" }
        end
      end
    end
  end
end
