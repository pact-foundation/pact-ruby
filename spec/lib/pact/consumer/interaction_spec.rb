require 'spec_helper'

module Pact
  module Consumer
    describe Interaction do

      subject { Interaction.new(producer, 'Test request').with(request) }

      let(:pact_path) { File.expand_path('../../../../pacts/mock', __FILE__) }

      let(:request) do
        { method: 'post', path: '/foo', body: Term.new(generate: 'waffle', match: /ffl/) }
      end

      let(:response) do
        { baz: /qux/, wiffle: Term.new(generate: 'wiffle', match: /iff/) }
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
              body: Term.new(generate: 'waffle', match: /ffl/)
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
          expect(parsed_result['request']).to eq({'method' => 'post', 'path' => '/foo', 'body' => Pact::Term.new(generate: 'waffle', match: /ffl/) })
        end

        describe "response" do

          it "serialises regexes" do
            expect(parsed_result['response']['baz']).to eql /qux/
          end

          it "serialises terms" do
            term = Pact::Term.new(generate:'wiffle', match: /iff/)
            parsed_term = parsed_result['response']['wiffle']
            expect(term.match).to eql parsed_term.match
            expect(term.generate).to eql parsed_term.generate
          end

        end

      end
    end
  end
end
