require 'spec_helper'

module Pact
  describe HashQuery do

    let(:hash_query) { HashQuery.new(query) }
    let(:query) { {} }

    describe '#==' do

      let(:this_query) { hash_query }

      context 'when other is a HashQuery' do
        context 'when both queries are the same' do
          let(:other_hash_query) { hash_query }

          it 'matches' do
            expect(this_query).to eq(other_hash_query)
          end
        end

        context 'when both queries are not the same' do
          let(:other_hash_query) { HashQuery.new({not: 'the_same'}) }

          it 'matches' do
            expect(this_query).to_not eq(other_hash_query)
          end
        end
      end

      context 'when other is a string' do
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

    describe '#to_hash' do
      let(:query) { {foo: 'bar'} }

      it 'returns a hash serialising the class' do
        expect(hash_query.to_hash).to eq({json_class: 'Pact::HashQuery', data: {query: query} })
      end
    end

    describe '#as_json' do
      let(:query) { {foo: 'bar'} }

      it 'returns a hash serialising the class' do
        expect(hash_query.as_json).to eq({json_class: 'Pact::HashQuery', data: {query: query} })
      end
    end

    describe '#to_s' do
      let(:query) { { 'first' => 'one', 'second' => 'two' } }

      it 'returns a query string' do
        expect(hash_query.to_s).to eq('first=one&second=two')
      end
    end

    describe '#empty' do
      context 'when query is present' do
        let(:query) { {foo: 'bar'} }

        it 'returns false' do
          expect(query.empty?).to be false
        end
      end

      context 'when query is not present' do
        let(:query) { {} }

        it 'returns true' do
          expect(query.empty?).to be true
        end
      end
    end

  end
end