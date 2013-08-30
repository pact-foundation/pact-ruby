require 'spec_helper'
require 'pact/reification'
require 'pact/consumer_contract/interaction'

module Pact
  module Consumer

    describe Interaction do

      describe "==" do
        subject { InteractionFactory.create }
        context "when other is the same" do
          let(:other) { InteractionFactory.create }
          it "returns true" do
            expect(subject == other).to be_true
          end
        end
        context "when other is not the same" do
          let(:other) { InteractionFactory.create(:request => {:path => '/a_different_path'}) }
          it "returns false" do
            expect(subject == other).to be_false
          end
        end
      end

      describe "matches_criteria?" do
        subject { InteractionFactory.create(:description => 'a request for food') }
        context "by description" do
          context "when the interaction matches" do
            it "returns true" do
              expect(subject.matches_criteria?(:description => /request.*food/)).to be_true 
            end
          end
          context "when the interaction does not match" do
            it "returns false" do
              expect(subject.matches_criteria?(:description => /blah/)).to be_false
            end
          end
        end
      end

      describe "as_json_for_mock_service" do
        let(:as_json_with_options ) { {:opts => 'blah'} }
        let(:request) { double(Pact::Request::Expected, :as_json_with_options => {:opts => 'blah'})}
        let(:response) { double('response') }
        let(:generated_response ) { double('generated_response', :to_json => 'generated_response') }
        subject { Interaction.new(:description => 'description', :request => request, :response => response, :provider_state => 'some state')}
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

        it "includes the provider state" do
          expect(subject.as_json_for_mock_service[:provider_state]).to eq 'some state'
        end

        it "includes the description" do
          expect(subject.as_json_for_mock_service[:description]).to eq 'description'
        end

        it "doesn't have any other keys" do
          expect(subject.as_json_for_mock_service.keys).to eq [:response, :request, :description, :provider_state]
        end
      end

      describe "to JSON" do
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

        let(:parsed_result) do
          JSON.load(JSON.dump(subject))
        end

        subject { Interaction.from_hash('response' => response, 'request' => request) }

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

      end
    end
  end
end
