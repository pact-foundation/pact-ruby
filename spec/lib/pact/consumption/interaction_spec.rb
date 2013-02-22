require 'spec_helper'

module Pact
  module Consumption
    describe Interaction do

      subject { Interaction.new(producer, request) }

      let(:pact_path) { File.expand_path('../../../../pacts/mock', __FILE__) }
      let(:request) { { foo: 'bar' } }
      let(:response_spec) { { baz: /qux/ } }

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
          interaction_json = {
            request: {
              foo: 'bar'
            },
            response: {
              baz: 'qux'
            }
          }.to_json

          subject.will_respond_with response_spec
          WebMock.should have_requested(:post, 'example.com:2222/interactions').with(body: interaction_json)
        end

        it "updates the Producer's Pactfile" do
          producer.should_receive(:update_pactfile)
          subject.will_respond_with response_spec
        end

        it "returns the producer (for fluent API goodness)" do
          expect(subject.will_respond_with response_spec).to eql producer
        end

      end

      describe "to JSON" do

        before do
          subject.will_respond_with response_spec
        end

        it "contains the request" do
          expect(subject.to_json[:request]).to eql({foo: 'bar'})
        end

        it "contains the response spec" do
          expect(subject.to_json[:response]).to eql({baz: /qux/})
        end

      end
    end
  end
end
