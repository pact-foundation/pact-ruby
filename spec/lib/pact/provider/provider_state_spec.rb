require 'spec_helper'
require 'pact/provider/provider_state'

module Pact
  module Provider

    describe 'global ProviderState' do

      MESSAGES = []

      Pact.provider_state :no_alligators do
        set_up do
          MESSAGES << 'set_up'
        end
        tear_down do
          MESSAGES << 'tear_down'
        end
      end

      Pact.provider_state 'some alligators' do
        no_op
      end

      before do
        MESSAGES.clear
      end

      subject { ProviderStates.get('no_alligators') }

      describe 'set_up' do
        it 'should call the block passed to set_up' do
          subject.set_up
          MESSAGES.should eq ['set_up']
        end
      end

      describe 'tear_down' do
        it 'should call the block passed to set_up' do
          subject.tear_down
          MESSAGES.should eq ['tear_down']
        end
      end

      describe '.get' do
        context 'when the name is a matching symbol' do
          it 'will return the ProviderState' do
            ProviderStates.get('no_alligators').should_not be_nil
          end
        end
        context 'when the name is a matching string' do
          it 'will return the ProviderState' do
            ProviderStates.get('some alligators').should_not be_nil
          end
        end
      end
    end

    describe 'no_op' do
      context "when a no_op is defined instead of a set_up or tear_down" do
        it "treats set_up and tear_down as empty blocks" do
          Pact.provider_state 'with_no_op' do
            no_op
          end
          ProviderStates.get('with_no_op').set_up
          ProviderStates.get('with_no_op').tear_down
        end
      end
      context "when a no_op is defined with a set_up" do
        it "raises an error" do
          expect do
            Pact.provider_state 'with_no_op_and_set_up' do
              no_op
              set_up do

              end
            end.to raise_error(/Provider state \"with_no_op_and_set_up\" has been defined as a no_op but it also has a set_up block. Please remove one or the other./)
          end
        end
      end
      context "when a no_op is defined with a tear_down" do
        it "raises an error" do
          expect do
            Pact.provider_state 'with_no_op_and_set_up' do
              no_op
              tear_down do

              end
            end.to raise_error(/Provider state \"with_no_op_and_set_up\" has been defined as a no_op but it also has a tear_down block. Please remove one or the other./)
          end
        end
      end

    end


    describe 'namespaced ProviderStates' do

      NAMESPACED_MESSAGES = []

      Pact.provider_states_for 'a consumer' do
        provider_state 'the weather is sunny' do
          set_up do
            NAMESPACED_MESSAGES << 'sunny!'
          end
        end
      end

      Pact.provider_state 'the weather is cloudy' do
        set_up do
          NAMESPACED_MESSAGES << 'cloudy :('
        end
      end

      before do
        NAMESPACED_MESSAGES.clear
      end

      describe '.get' do
        context 'for a consumer' do
          it 'has a namespaced name' do
            ProviderStates.get('the weather is sunny', :for => 'a consumer').should_not be_nil
          end

          it 'falls back to a global state of the same name if one is not found for the specified consumer' do
            ProviderStates.get('the weather is cloudy', :for => 'a consumer').should_not be_nil
          end
        end

      end

      describe 'set_up' do
        context 'for a consumer' do
          it 'runs its own setup' do
            ProviderStates.get('the weather is sunny', :for => 'a consumer').set_up
            NAMESPACED_MESSAGES.should eq ['sunny!']
          end
        end
      end
    end

    describe "invalid provider state" do
      context "when no set_up or tear_down is provided" do
        it "raises an error to prevent someone forgetting about the set_up and putting the set_up code directly in the provider_state block and wasting 20 minutes trying to work out why their provider states aren't working properly" do
          expect do
            Pact.provider_state 'invalid' do
            end
          end.to raise_error(/Please provide a set_up or tear_down block for provider state \"invalid\"/)
        end
      end
      context "when a no_op is defined" do
        it "does not raise an error" do
          expect do
            Pact.provider_state 'valid' do
              no_op
            end
          end.not_to raise_error
        end
      end
    end
  end
end
