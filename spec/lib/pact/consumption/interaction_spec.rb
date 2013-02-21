require 'spec_helper'

module Pact
  module Consumption
    describe Interaction do

      subject { Interaction.new(mock_producer, request) }

      let(:mock_producer) { double(uri: URI('http://example.com:2222')) }
      let(:request) { { foo: 'bar' } }

      before do
        stub_request(:post, 'example.com:2222/interactions')
      end

      describe "setting up response specifications" do

        let(:response_spec) { { baz: /qux/ } }

        before do
          subject.will_respond_with response_spec
        end

        it "creates a response with the provided specification" do
          expect(subject.response).to have_specification response_spec
        end

        it "posts the reified interaction to the mock service" do
          interaction_json = {
            request: {
              foo: 'bar'
            },
            response: {
              baz: 'qux'
            }
          }.to_json

          WebMock.should have_requested(:post, 'example.com:2222/interactions').with(body: interaction_json)
        end

      end

    end
  end
end
