require 'spec_helper'
require 'fileutils'
require 'pathname'

module Pact
  module Consumer
    describe ConsumerContractBuilder do

      let(:consumer_name) { 'a consumer' }
      let(:provider_name) { 'a provider' }

      describe "handle_interaction_fully_defined" do

        subject {
          Pact::Consumer::ConsumerContractBuilder.new(:consumer_name => 'blah', :provider_name => 'blah', :port => 2222)
        }

        let(:interaction_hash) {
          {
            description: 'Test request',
            request: {
              method: 'post',
              path: '/foo',
              body: Term.new(generate: 'waffle', matcher: /ffl/),
              headers: { 'Content-Type' => 'application/json' },
              query: "",
            },
            response: {
              baz: 'qux',
              wiffle: 'wiffle'
            }
          }
        }

        let(:interaction_json) { {} }

        let(:interaction) { Pact::Interaction.from_hash(JSON.load(interaction_hash.to_json)) }

        before do
          stub_request(:post, 'localhost:2222/interactions')
        end

        it "posts the interaction with generated response to the mock service" do
          subject.handle_interaction_fully_defined interaction
          expect(WebMock).to have_requested(:post, 'localhost:2222/interactions').with(body: interaction_json)
        end

        it "resets the interaction_builder to nil" do
          expect(subject).to receive(:interaction_builder=).with(nil)
          subject.handle_interaction_fully_defined interaction
        end
      end

      describe "#mock_service_base_url" do

      	subject {
      		ConsumerContractBuilder.new(
      			:pactfile_write_mode => :overwrite,
            :consumer_name => consumer_name,
            :provider_name => provider_name,
        		:port => 1234) }

      	it "returns the mock service base URL" do
      		expect(subject.mock_service_base_url).to eq("http://localhost:1234")
      	end
      end
    end
  end
end
