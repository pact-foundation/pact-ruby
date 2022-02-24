require 'pact/provider/verification_results/create'

module Pact
  module Provider
    module VerificationResults
      describe Create do
        before do
          allow(Pact.configuration).to receive(:provider).and_return(provider_configuration)
          allow(VerificationResult).to receive(:new).and_return(verification_result)
        end

        let(:verification_result) { double('VerificationResult') }
        let(:provider_configuration) do
          double('provider_configuration', application_version: '1.2.3', build_url: ci_build)
        end
        let(:ci_build) { 'http://ci/build/1' }
        let(:pact_source_1) do
          instance_double('Pact::Provider::PactSource', uri: pact_uri_1, consumer_contract: consumer_contract)
        end
        let(:consumer_contract) { instance_double('Pact::ConsumerContract', interactions: interactions)}
        let(:interactions) { [interaction_1] }
        let(:interaction_1) { instance_double('Pact::Interaction', _id: "1") }
        let(:interaction_2) { instance_double('Pact::Interaction', _id: "2") }
        let(:pact_uri_1) { instance_double('Pact::Provider::PactURI', uri: URI('foo')) }
        let(:pact_uri_2) { instance_double('Pact::Provider::PactURI', uri: URI('bar')) }
        let(:example_1) do
          {
            pact_uri: pact_uri_1,
            pact_interaction: interaction_1,
            status: 'passed'
          }
        end
        let(:example_2) do
          {
            pact_uri: pact_uri_2,
            pact_interaction: interaction_2,
            status: 'passed'
          }
        end
        let(:test_results_hash) do
          {
            tests: [example_1, example_2]
          }
        end

        subject { Create.call(pact_source_1, test_results_hash) }

        it "returns a verification result" do
          expect(subject).to eq verification_result
        end

        it "creates a VerificationResult with the relevant test results" do
          expected_test_results_hash = {
            tests: [{ status: "passed" }],
            summary: { testCount: 1, failureCount: 0},
            metadata: {
              warning: "These test results use a beta format. Do not rely on it, as it will definitely change.",
              pactVerificationResultsSpecification: {
                version: "1.0.0-beta.1"
              }
            }
          }
          expect(VerificationResult).to receive(:new).with(anything, anything, anything, expected_test_results_hash, anything)
          subject
        end

        it "creates a VerificationResult with the provider application version" do
          expect(provider_configuration).to receive(:application_version)
          expect(VerificationResult).to receive(:new).with(anything, anything, '1.2.3', anything, anything)
          subject
        end

        it "creates a VerificationResult with the provider ci build url" do
          expect(provider_configuration).to receive(:build_url)
          expect(VerificationResult).to receive(:new).with(anything, anything, anything, anything, ci_build)
          subject
        end

        context "when every interaction has been executed" do
          it "sets publishable to true" do
            expect(VerificationResult).to receive(:new).with(true, anything, anything, anything, anything)
            subject
          end
        end

        context "when not every interaction has been executed" do
          let(:interaction_3) { instance_double('Pact::Interaction', _id: "3") }
          let(:interactions) { [interaction_1, interaction_2]}

          it "sets publishable to false" do
            expect(VerificationResult).to receive(:new).with(false, anything, anything, anything, anything)
            subject
          end
        end

        context "when all the examples passed" do
          it "sets the success to true" do
            expect(VerificationResult).to receive(:new).with(anything, true, anything, anything, anything)
            subject
          end
        end

        context "when not all the examples passed" do
          before do
            example_1[:status] = 'notpassed'
          end

          it "sets the success to false" do
            expect(VerificationResult).to receive(:new).with(anything, false, anything, anything, anything)
            subject
          end

          it "sets the failureCount" do
            expect(VerificationResult).to receive(:new) do | _, _, _, test_results_hash|
              expect(test_results_hash[:summary][:failureCount]).to eq 1
            end
            subject
          end
        end
      end
    end
  end
end
