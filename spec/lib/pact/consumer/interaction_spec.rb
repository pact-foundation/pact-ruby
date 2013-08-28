require 'spec_helper'

module Pact
  module Consumer
    describe InteractionBuilder do

      subject { 
        interaction_builder = InteractionBuilder.new('Test request', nil).with(request) 
        interaction_builder.on_interaction_fully_defined do | interaction |
          producer.callback interaction
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

      let(:producer) do
        double(callback: nil)
      end

      describe "setting up responses" do

        it "invokes the callback" do
          producer.should_receive(:callback).with(subject.interaction)
          subject.will_respond_with response
        end

      end

      describe "as_json_for_mock_service" do
        let(:as_json_with_options ) { {:opts => 'blah'} }
        let(:request) { double(Pact::Request::Expected, :as_json_with_options => {:opts => 'blah'})}
        let(:response) { double('response') }
        let(:generated_response ) { double('generated_response', :to_json => 'generated_response') }
        subject { Interaction.new(:description => 'description', :request => request, :response => response, :producer_state => 'some state')}
        let(:expected_hash) { {:response => generated_response, :request => as_json_with_options, :description => '' } }

        before do
          Reification.stub(:from_term).with(response).and_return(generated_response)
        end

        it "generates an actual response" do
          Reification.should_receive(:from_term).with(response).and_return(generated_response)
          expect(subject.as_json_for_mock_service[:response]).to eq generated_response
        end

        it "includes the options in the request" do
          expect(subject.as_json_for_mock_service[:request]).to eq as_json_with_options
        end

        it "includes the producer state" do
          expect(subject.as_json_for_mock_service[:producer_state]).to eq 'some state'
        end

        it "includes the description" do
          expect(subject.as_json_for_mock_service[:description]).to eq 'description'
        end

        it "doesn't have any other keys" do
          expect(subject.as_json_for_mock_service.keys).to eq [:response, :request, :description, :producer_state]
        end
      end

      describe "to JSON" do

        let(:parsed_result) do
          JSON.load(JSON.dump(subject.interaction))
        end

        before do
          subject.will_respond_with response
        end

        it "contains the request" do
          expect(parsed_result['request']).to eq({
              'method' => 'post',
              'path' => '/foo',
              'headers' => {
                'Content-Type' => 'application/json'
              },
              'body' => Term.new(generate: 'waffle', matcher: /ffl/),
              'query' => ''
            })
        end

        describe "response" do

          it "serialises regexes" do
            expect(parsed_result['response']['baz']).to eql /qux/
          end

          it "serialises terms" do
            term = Term.new(generate:'wiffle', matcher: /iff/)
            parsed_term = parsed_result['response']['wiffle']
            expect(term.matcher).to eql parsed_term.matcher
            expect(term.generate).to eql parsed_term.generate
          end

        end

        context "with a producer_state" do
          context "described with a string" do
            subject { 
              interaction_builder = InteractionBuilder.new('Test request', "there are no alligators").with(request) 
              interaction_builder.on_interaction_fully_defined {}
              interaction_builder
            }

            it "includes the state name as a string" do
              expect(parsed_result['producer_state']).to eql("there are no alligators")
            end
          end
          context "described with a symbol" do
            subject { 
              interaction_builder = InteractionBuilder.new('Test request', :there_are_no_alligators).with(request) 
              interaction_builder.on_interaction_fully_defined {}
              interaction_builder
            }

            it "includes the state name as a symbol" do
              expect(parsed_result['producer_state']).to eql("there_are_no_alligators")
            end
          end
        end
      end
    end
  end
end
