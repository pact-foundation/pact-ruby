require 'spec_helper'
require 'fileutils'
require 'pathname'

module Pact
	module Consumer
		describe ConsumerContractBuilder do

		   describe "initialize" do
		   	SUPPORT_PACT_FILE = './spec/support/a_consumer-a_provider.json'
			   before do
			      Pact.clear_configuration
			      Pact.configuration.stub(:pact_dir).and_return(File.expand_path(tmp_pact_dir))
			      FileUtils.rm_rf tmp_pact_dir
			      FileUtils.mkdir_p tmp_pact_dir
			      FileUtils.cp SUPPORT_PACT_FILE, "#{tmp_pact_dir}/a_consumer-a_provider.json"
			   end

			   let(:expected_interactions) { ConsumerContract.from_json(File.read(SUPPORT_PACT_FILE)).interactions }

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

			      it "uses an DistinctInteractionsFilter to handle new interactions" do
			      	Pact::Consumer::DistinctInteractionsFilter.should_receive(:new).with([])
			      	consumer_contract_builder
			      end
			   end

			   context "when updating pact" do
				   	before do

				   	end
			      let(:pactfile_write_mode) {:update}
			      it "loads the interactions from the existing pact file" do
			      	ConsumerContractBuilder.any_instance.stub(:info_and_puts)
			        expect(consumer_contract_builder.consumer_contract.interactions).to eq expected_interactions
			      end

			      it "uses an UpdatableInteractionsFilter to handle new interactions" do
			      	ConsumerContractBuilder.any_instance.stub(:info_and_puts)
			      	Pact::Consumer::UpdatableInteractionsFilter.should_receive(:new).with(expected_interactions)
			      	consumer_contract_builder
			      end

			      let(:line0) { /\*/ }
			      let(:line1) { /Updating existing file/ }
			      let(:line2) { /Only interactions defined in this test run will be updated/ }
			      let(:line3) { /As interactions are identified by description and provider state/ }
			      it "logs a description message" do
			      	$stdout.should_receive(:puts).with(line0).twice
			      	$stdout.should_receive(:puts).with(line1)
			      	$stdout.should_receive(:puts).with(line2)
			      	$stdout.should_receive(:puts).with(line3)
			      	Pact.configuration.logger.should_receive(:info).with(line0).twice
			      	Pact.configuration.logger.should_receive(:info).with(line1)
			      	Pact.configuration.logger.should_receive(:info).with(line2)
			      	Pact.configuration.logger.should_receive(:info).with(line3)
			      	consumer_contract_builder
			      end
			   end

			   context "when an error occurs deserializing the existing pactfile" do
			   	let(:pactfile_write_mode) {:update}
			   	let(:error) { RuntimeError.new('some error')}
			   	let(:line1) { /Could not load existing consumer contract from .* due to some error/ }
			   	let(:line2) {'Creating a new file.'}
			   	before do
			   		ConsumerContract.stub(:from_json).and_raise(error)
			   		$stderr.should_receive(:puts).with(line1)
			   		$stderr.should_receive(:puts).with(line2)
			   		Pact.configuration.logger.should_receive(:warn).with(line1)
			   		Pact.configuration.logger.should_receive(:warn).with(line2)
			   	end
			   	it "logs the error" do
			   		consumer_contract_builder
			   	end

			   	it "continues with a new file" do
			   		expect(consumer_contract_builder.consumer_contract.interactions).to eq []
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

				let(:interaction) { Pact::Interaction.from_hash(JSON.load(interaction_hash.to_json)) }

				before do
					stub_request(:post, 'localhost:2222/interactions')
				end

	      	it "posts the interaction with generated response to the mock service" do
		        	subject.handle_interaction_fully_defined interaction
		        	WebMock.should have_requested(:post, 'localhost:2222/interactions').with(body: interaction_json)
	      	end

	      	it "adds the interaction to the consumer contract" do
	      		subject.handle_interaction_fully_defined interaction
	      		expect(subject.consumer_contract.interactions).to eq [interaction]
	      	end

	      	it "updates the provider's pactfile" do
	      		subject.consumer_contract.should_receive(:update_pactfile)
	      		subject.handle_interaction_fully_defined interaction
	      	end

	      	it "resets the interaction_builder to nil" do
	      		subject.should_receive(:interaction_builder=).with(nil)
	      		subject.handle_interaction_fully_defined interaction
	      	end
			end
		end
	end
end