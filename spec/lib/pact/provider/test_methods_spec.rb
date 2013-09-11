require 'spec_helper'
require 'pact/provider/test_methods'

module Pact::Provider
  describe TestMethods do

    class TestHelper
      include TestMethods
    end

    subject { TestHelper.new }

    describe "get_provider_state" do
      it "raises a descriptive error if the provider state is not found" do
        ProviderState.stub(:get).and_return(nil)
        expect{ subject.send(:get_provider_state, 'some state', 'consumer') }.to raise_error /Could not find.*some state.*consumer.*/
      end
    end

    describe 'request path' do

      let(:request) { OpenStruct.new(:path => 'path', :query => query)}

      before do
        @path = subject.send(:request_path, request)
      end

      describe 'query' do

        context 'string query' do

          let(:query) { 'query' }

          it 'gets appended to the path' do
            expect(@path).to eq('path?query')
          end
        end

        context 'Term query' do

          let(:query) { Pact::Term.new(generate: 'query') }

          it 'appends the Term\'s generate to the path' do
            expect(@path).to eq('path?query')
          end
        end
      end
    end
  end
end