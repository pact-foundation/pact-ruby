require 'spec_helper'

module Pact
  describe HashQuery do

    describe '#==' do

      let(:this_query) { HashQuery.new(query) }
      let(:other_string_query) { 'second=two&first=one' }

      context 'given another Query object with different sort order' do
        let(:query) { {first: 'one', second: 'two'} }

        it 'compares query parameters without ordering' do
          expect(this_query).to eq(other_string_query)
        end
      end

      context 'when query has string keys' do
        let(:query) { { 'first' => 'one', 'second' => 'two' } }

        it 'matches' do
          expect(this_query).to eq(other_string_query)
        end
      end

    end

  end
end