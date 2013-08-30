require 'spec_helper'
require 'pact/consumer/interactions'

module Pact::Consumer

   describe 'Interactions' do
      let(:interaction) { InteractionFactory.create }
      let(:indentical_interaction) { InteractionFactory.create }
      let(:interaction_with_diff_request) { InteractionFactory.create :request => {:path => '/different'} }
      let(:interaction_with_diff_description) { InteractionFactory.create :description => 'blah' }
      let(:interaction_with_diff_provider_state) { InteractionFactory.create :provider_state => 'blah' }

      shared_examples_for 'interactions' do

         subject { described_class.new([interaction]) }

         describe "include?" do
            context "when an interaction exists with the same provider state and description" do
               it "returns true" do
                  expect(subject.include?(interaction_with_diff_request)).to be_true
               end
            end         
            context "when an interaction with the same provider state and description is not included" do
               it "returns false" do
                  expect(subject.include?(interaction_with_diff_description)).to be_false
                  expect(subject.include?(interaction_with_diff_provider_state)).to be_false
               end
            end         
         end

         describe "<<" do
            context "when an interaction with the same provider state and description is not already included" do
               it "adds the interaction" do
                  subject << interaction_with_diff_description
                  expect(subject).to eq [interaction, interaction_with_diff_description]
               end
            end
         end
      end

      describe UpdatableInteractions do
         include_examples 'interactions'
         describe "<<" do
            context "when an interaction with the same provider state and description is already included" do
               it "overwrites the old interaction" do
                  subject << interaction_with_diff_request
                  expect(subject).to eq [interaction_with_diff_request]
               end
            end 
         end
      end

      describe DistinctInteractions do
         include_examples 'interactions'
         describe "<<" do
            context "when an interaction with the same provider state and description is already included" do
               context "when the interactions are not equal" do
                  it "raises an error" do
                     expect{ subject << interaction_with_diff_request }.to raise_error 'Interaction with same description (a description) and provider state (a thing exists) already exists'
                  end
               end
               context "when the interactions are equal" do
                  it "does not add the interaction" do
                     subject << indentical_interaction
                     expect(subject).to eq [interaction]
                  end
               end
            end          
         end
      end   
   end

end