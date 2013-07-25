require 'spec_helper'

module Pact
  module Consumer
    describe Interaction do

      subject { Interaction.new(producer, 'Test request', nil).with(request) }

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
        double(uri: URI('http://example.com:2222'),
               pact_path: pact_path,
               update_pactfile: nil)
      end

      before do
        stub_request(:post, 'example.com:2222/interactions')
      end

      describe "setting up responses" do

        it "posts the interaction with generated response to the mock service" do
          interaction_json = JSON.dump({
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
          })

          subject.will_respond_with response
          WebMock.should have_requested(:post, 'example.com:2222/interactions').with(body: interaction_json)
        end

        it "updates the Producer's Pactfile" do
          producer.should_receive(:update_pactfile)
          subject.will_respond_with response
        end

        it "returns the producer (for fluent API goodness)" do
          expect(subject.will_respond_with response).to eql producer
        end

      end

      describe "to JSON" do

        let(:parsed_result) do
          JSON.load(JSON.dump(subject))
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
            subject { Interaction.new(producer, 'Test request', "there are no alligators").with(request) }

            it "includes the state name as a string" do
              expect(parsed_result['producer_state']).to eql("there are no alligators")
            end
          end
          context "described with a symbol" do
            subject { Interaction.new(producer, 'Test request', :there_are_no_alligators).with(request) }

            it "includes the state name as a symbol" do
              expect(parsed_result['producer_state']).to eql("there_are_no_alligators")
            end
          end
        end
      end
    end
  end
end
