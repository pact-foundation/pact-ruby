require 'spec_helper'
require 'pact/producer/producer_state'

module Pact
  module Producer

    describe 'global ProducerState' do

      MESSAGES = []

      producer_state :no_alligators do
        set_up do
          MESSAGES << 'set_up'
        end
        tear_down do
          MESSAGES << 'tear_down'
        end
      end

      producer_state 'some alligators' do
      end

      before do
        MESSAGES.clear
      end

      subject { ProducerState.get('no_alligators') }

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
          it 'will return the ProducerState' do
            ProducerState.get('no_alligators').should_not be_nil
          end
        end
        context 'when the name is a matching string' do
          it 'will return the ProducerState' do
            ProducerState.get('some alligators').should_not be_nil
          end
        end
      end
    end


    describe 'namespaced ProducerStates' do

      NAMESPACED_MESSAGES = []

      consumer :ns_one do
        producer_state 'foo' do
          set_up do
            NAMESPACED_MESSAGES << 'ns_one.foo'
          end
        end
      end

      consumer :ns_two do
        consumer :ns_three do
          producer_state 'foo' do
            set_up do
              NAMESPACED_MESSAGES << 'ns_two.ns_three.foo'
            end
          end
        end
      end

      before do
        NAMESPACED_MESSAGES.clear
      end

      describe '.get' do

        context 'the first namespace' do

          it 'has a namespaced name' do
            ProducerState.get('ns_one.foo').should_not be_nil
          end
        end

        context 'the second namespace' do

          it 'has a namespaced name' do
            ProducerState.get('ns_two.ns_three.foo').should_not be_nil
          end
        end

      end

      describe 'set_up' do

        context 'the first namespace' do

          it 'runs its own setup' do
            ProducerState.get('ns_one.foo').set_up
            NAMESPACED_MESSAGES.should eq ['ns_one.foo']
          end
        end

        context 'the second namespace' do

          it 'runs its own setup' do
            ProducerState.get('ns_two.ns_three.foo').set_up
            NAMESPACED_MESSAGES.should eq ['ns_two.ns_three.foo']
          end
        end
      end
    end
  end
end
