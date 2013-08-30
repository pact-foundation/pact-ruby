require 'spec_helper'
require 'pact/consumer'

module Pact
   describe "building a consumer contract" do
      before do
         Pact.configuration.stub(:pact_dir).and_return(File.expand_path('./tmp'))
         Pact::Consumer::MockServiceClient.stub(:new).and_return(double('MockServiceClient').as_null_object)
      end
      let(:response_hash) { ResponseFactory.create_hash }
      let(:request_hash) { RequestFactory.create_hash }
      let(:description) { 'a request'}
      let(:provider_state) { 'a thing exists'}
      let(:interaction) { InteractionFactory.create( 
                                       :request => request_hash, 
                                       :response => response_hash, 
                                       :description => description, 
                                       :provider_state => provider_state)}
      let(:interactions) {[interaction] }
      let(:consumer_name) { 'consumer'}
      let(:provider_name) { 'provider'}
      
      subject { Consumer::ConsumerContractBuilder.new(:consumer_name => consumer_name, :provider_name => provider_name, :pactfile_write_mode => pactfile_write_mode, :port => 1234) }
      
      let(:different_request_hash) { RequestFactory.create_hash :path => '/similar_request' }

      #let(:interaction) { Pact::Interaction.new(description: description, request: Request::Expected.from_hash(request_hash), response: response_hash, provider_state: provider_state ) }
      let(:similar_interaction)  { Pact::Interaction.new(description: description, request: Request::Expected.from_hash(different_request_hash), response: response_hash, provider_state: provider_state ) }


      let(:new_description) { 'a new request'}
      let(:different_new_description) { 'a different new request'}
      let(:new_interaction) { Pact::Interaction.new(description: new_description, request: Request::Expected.from_hash(different_request_hash), response: response_hash, provider_state: provider_state ) }
      let(:different_new_interaction) { Pact::Interaction.new(description: new_description, request: Request::Expected.from_hash(different_request_hash), response: response_hash, provider_state: provider_state ) }

      def add_duplicate_interaction
         subject.given(provider_state).upon_receiving(description).with(request_hash).will_respond_with(response_hash)
      end

      def add_interaction_which_will_be_accidentally_copied
         subject.given(provider_state).upon_receiving(description).with(request_hash).will_respond_with(response_hash)
      end

      def add_similar_interaction
         subject.given(provider_state).upon_receiving(description).with(different_request_hash).will_respond_with(response_hash)
      end

      def add_new_interaction
         subject.given(provider_state).upon_receiving(new_description).with(different_request_hash).will_respond_with(response_hash)
      end

      def add_different_new_interaction
         subject.given(provider_state).upon_receiving(different_new_description).with(request_hash).will_respond_with(response_hash)
      end

      describe "when pactfile_write_mode is :overwrite (by default, when running rake)" do
         let(:pactfile_write_mode) {:overwrite}
         context "when duplicate interactions are added" do
            before do
               add_new_interaction
               add_new_interaction
            end

            it "it keeps the original interaction" do
               expect(subject.consumer_contract.interactions.first).to eq new_interaction
            end

            it "does not add the second interaction" do
               expect(subject.consumer_contract.interactions.size).to eq 1
            end
         end
         context "when a different new interaction is added" do
            before do
               add_new_interaction
               add_different_new_interaction
            end
            it "is added" do
               expect(subject.consumer_contract.interactions.size).to eq 2
            end
         end
         context "when an interaction is added with the same description and provider state but not otherwise equal to an existing interaction" do
            before do
               add_interaction_which_will_be_accidentally_copied
            end        
            it "raises an error as the user has most likely copy/pasted an existing interaction" do
               expect{ add_similar_interaction }.to raise_error 'Interaction with same description (a request) and provider state (a thing exists) already exists'
            end
         end
      end
      describe "when pactfile_write_mode is :update (by default when running a single test)" do
         let(:consumer_contract) { ConsumerContractFactory.create consumer_name: consumer_name, provider_name: provider_name, interactions: interactions }

         before do
            consumer_contract.update_pactfile
         end         
         let(:pactfile_write_mode) {:update}
         context "when a duplicate interaction is added" do
            before do
               add_duplicate_interaction
            end
            
            it "it keeps the original interaction" do
               expect(subject.consumer_contract.interactions.last).to eq interaction
            end

            it "does not add the second interaction" do
               expect(subject.consumer_contract.interactions.size).to eq 1
            end
         end
         context "when a different new interaction is added" do
            before do
               add_different_new_interaction
            end
            it "is added" do
               expect(subject.consumer_contract.interactions.size).to eq 2
            end
         end         
         context "when an interaction is added with the same description and provider state but not otherwise equal to an existing interaction" do
            before do
               add_similar_interaction
            end 
            it "overwrites the existing interaction, the user has most likely updated the test, and is just regenerating the one file" do
               expect(subject.consumer_contract.interactions.last).to eq similar_interaction
               expect(subject.consumer_contract.interactions.size).to eq 1
            end
         end         
      end      
   end
end