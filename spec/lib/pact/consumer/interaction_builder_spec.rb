require 'spec_helper'
require 'pact/consumer/interaction_builder'

module Pact
  module Consumer
    describe InteractionBuilder do

      subject { 
        interaction_builder = InteractionBuilder.new('Test request', nil).with(request) 
        interaction_builder.on_interaction_fully_defined do | interaction |
          provider.callback interaction
        end
        interaction_builder
      }

      let(:pact_path) { File.expand_path('../../../../pacts/mock', __FILE__) }

      let(:request) do
        {
          method: 'post',
          path: '/foo',
          body: Term.new(generate: 'waffle', matcher: /ffl/),
          headers: { 'Content-Type' => 'application/json' },
          query: '',
        }
      end

      let(:response) do
        { baz: /qux/, wiffle: Term.new(generate: 'wiffle', matcher: /iff/) }
      end

      let(:provider) do
        double(callback: nil)
      end

      describe "setting up responses" do

        it "invokes the callback" do
          provider.should_receive(:callback).with(subject.interaction)
          subject.will_respond_with response
        end

      end

      context "with a provider_state" do
        let(:parsed_result) do
          JSON.load(JSON.dump(subject.interaction))
        end
        context "described with a string" do
          subject { 
            interaction_builder = InteractionBuilder.new('Test request', "there are no alligators").with(request) 
            interaction_builder.on_interaction_fully_defined {}
            interaction_builder
          }

          it "includes the state name as a string" do
            expect(parsed_result['provider_state']).to eql("there are no alligators")
          end
        end
        context "described with a symbol" do
          subject { 
            interaction_builder = InteractionBuilder.new('Test request', :there_are_no_alligators).with(request) 
            interaction_builder.on_interaction_fully_defined {}
            interaction_builder
          }

          it "includes the state name as a symbol" do
            expect(parsed_result['provider_state']).to eql("there_are_no_alligators")
          end
        end
      end
    end
  end
end
