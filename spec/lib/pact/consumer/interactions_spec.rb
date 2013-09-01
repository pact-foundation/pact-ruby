require 'spec_helper'
require 'pact/consumer/interactions'

module Pact::Consumer

   describe 'Interactions' do
      let(:interaction) { InteractionFactory.create }
      let(:indentical_interaction) { InteractionFactory.create }
      let(:interaction_with_diff_request) { InteractionFactory.create :request => {:path => '/different'} }
      let(:interaction_with_diff_description) { InteractionFactory.create :description => 'blah' }
      let(:interaction_with_diff_provider_state) { InteractionFactory.create :provider_state => 'blah' }
      let(:interactions) { [interaction] }
      shared_examples_for 'interactions' do

         subject { described_class.new(interactions) }

         describe "<<" do
            context "when an interaction with the same provider state and description is not already included" do
               it "adds the interaction" do
                  subject << interaction_with_diff_description
                  expect(interactions).to eq [interaction, interaction_with_diff_description]
               end
            end
         end
      end

      describe UpdatableInteractionsFilter do
         context "which, by default, is used when running rspec" do
            include_examples 'interactions'
            describe "<<" do
               context "when an interaction with the same provider state and description is already included" do
                  it "overwrites the existing interaction, as the user has most likely just updated a test, and is rerunning the one spec" do
                     subject << interaction_with_diff_request
                     expect(interactions).to eq [interaction_with_diff_request]
                  end
               end 
            end
         end
      end

      describe DistinctInteractionsFilter do
         context "which, by default, this is used when running rake" do
            include_examples 'interactions'
            describe "<<" do
               context "when an interaction with the same provider state and description is already included" do
                  context "when the interactions are not equal" do
                     it "raises an error as the user has most likely copy/pasted an existing interaction and forgotten to update the description or provider state" do
                        expect{ subject << interaction_with_diff_request }.to raise_error 'Interaction with same description (a description) and provider state (a thing exists) already exists'
                     end
                  end
                  context "when the interactions are equal" do
                     it "does not add the interaction as it already exists" do
                        subject << indentical_interaction
                        expect(interactions).to eq [interaction]
                     end
                  end
               end          
            end
         end
      end   
   end

end