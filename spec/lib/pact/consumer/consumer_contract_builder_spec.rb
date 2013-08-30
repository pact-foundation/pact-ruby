require 'spec_helper'
require 'fileutils'
require 'pathname'

module Pact
	module Consumer
		describe ConsumerContractBuilder do

		   describe "initialize" do
			   before do
			      Pact.clear_configuration
			      Pact.configuration.stub(:pact_dir).and_return(File.expand_path(tmp_pact_dir))
			      FileUtils.rm_rf tmp_pact_dir
			      FileUtils.mkdir_p tmp_pact_dir
			      FileUtils.cp './spec/support/a_consumer-a_provider.json', "#{tmp_pact_dir}/a_consumer-a_provider.json"
			   end

			   let(:tmp_pact_dir) {"./tmp/pacts"}

			   let(:consumer_name) { 'a consumer' }
			   let(:provider_name) { 'a provider' }
			   let(:consumer_contract_builder) { 
			      Pact::Consumer::ConsumerContractBuilder.new(
			         :pactfile_write_mode => pactfile_write_mode,
			         :consumer_name => consumer_name,
			         :provider_name => provider_name,
			         :port => 1234)}

			   context "when overwriting pact" do
			      let(:pactfile_write_mode) {:overwrite}
			      it "it overwrites the existing pact file" do
			         expect(consumer_contract_builder.consumer_contract.interactions).to eq []
			      end
			   end

			   context "when updating pact" do
			      let(:pactfile_write_mode) {:update}
			      it "updates the existing pact file" do
			         expect(consumer_contract_builder.consumer_contract.interactions.size).to eq 2
			      end
			   end
		   end

			describe "handle_interaction_fully_defined" do

				subject {
					Pact::Consumer::ConsumerContractBuilder.new({:consumer_name => 'blah', :provider_name => 'blah', :port => 2222})
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

				let(:interaction_json) { interaction.to_json_for_mock_service }

				let(:interaction) { Pact::Consumer::Interaction.from_hash(JSON.parse(interaction_hash.to_json)) }

				before do
					stub_request(:post, 'localhost:2222/interactions')
				end

      	it "posts the interaction with generated response to the mock service" do
        	subject.handle_interaction_fully_defined interaction
        	WebMock.should have_requested(:post, 'localhost:2222/interactions').with(body: interaction_json)
      	end

      	it "updates the Provider's Pactfile" do
      		subject.consumer_contract.should_receive(:update_pactfile)
      		subject.handle_interaction_fully_defined interaction
      	end
			end
		end
	end
end