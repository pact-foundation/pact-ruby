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
        double(uri: URI('http://example.com:2222'),
               pact_path: pact_path,
               update_pactfile: nil,
               given: nil,
               callback: nil)
      end

      describe "setting up responses" do

        it "invokes the callback" do
          producer.should_receive(:callback).with(subject.interaction)
          subject.will_respond_with response
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
