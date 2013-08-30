require 'spec_helper'
require 'pact/consumer/interactions'

module Pact::Consumer

   describe 'Interactions' do
      let(:interaction1) { InteractionFactory.create }
      let(:interaction2) { InteractionFactory.create }
      let(:interaction3) { InteractionFactory.create :description => 'blah' }
      let(:interaction4) { InteractionFactory.create :request => {:path => '/different'} }
      let(:interaction5) { InteractionFactory.create :provider_state => 'blah' }

      shared_examples_for 'interactions' do

         subject { described_class.new([interaction1]) }

         describe "include?" do
            context "when an interaction exists with the same provider state and description" do
               it "returns true" do
                  expect(subject.include?(interaction4)).to be_true
               end
            end         
            context "when an interaction with the same provider state and description is not included" do
               it "returns false" do
                  expect(subject.include?(interaction3)).to be_false
                  expect(subject.include?(interaction5)).to be_false
               end
            end         
         end

         describe "<<" do
            context "when an interaction with the same provider state and description is not already included" do
               it "adds the interaction" do
                  subject << interaction3
                  expect(subject).to eq [interaction1, interaction3]
               end
            end
         end
      end

      describe UpdatableInteractions do
         include_examples 'interactions'
         describe "<<" do
            context "when an interaction with the same provider state and description is already included" do
               it "overwrites the old interaction" do
                  subject << interaction4
                  expect(subject).to eq [interaction4]
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
                     expect{ subject << interaction4 }.to raise_error 'Interaction with same description (a description) and provider state (a thing exists) already exists'
                  end
               end
               context "when the interactions are equal" do
                  it "does not add the interaction" do
                     subject << interaction2
                     expect(subject).to eq [interaction1]
                  end
               end
            end          
         end
      end   
   end

end