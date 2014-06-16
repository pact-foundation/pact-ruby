require 'spec_helper'
require 'pact/consumer_contract/request'
require 'pact/consumer/request'
require 'support/shared_examples_for_request'

module Pact

  describe Request::Expected do
    it_behaves_like "a request"

    let(:raw_request) do
      {
        'method' => 'get',
        'path' => '/mallory'
      }
    end

    describe "from_hash" do
      context "when optional field are not defined" do
        subject { described_class.from_hash(raw_request) }
        it "sets their values to NullExpectation" do
          expect(subject.body).to be_instance_of(Pact::NullExpectation)
          expect(subject.query).to be_instance_of(Pact::NullExpectation)
          expect(subject.headers).to be_instance_of(Pact::NullExpectation)
        end
      end
    end

    describe "as_json" do
      subject { Request::Expected.new(:get, '/path', {:header => 'value'}, {:body => 'yeah'}, "query", {some: 'options'}) }
      context "with options" do
        it "does not include the options because they are a temporary hack and should leave no trace of themselves in the pact file" do
          expect(subject.as_json.key?(:options)).to be false
        end
      end
    end

    describe "matching to actual requests" do

      subject { Request::Expected.new(expected_method, expected_path, expected_headers, expected_body, expected_query, options) }
      let(:options) { {} }

      let(:expected_method) { 'get' }
      let(:expected_path) { '/foo' }
      let(:expected_headers) { Pact::NullExpectation.new }
      let(:expected_body) { Pact::NullExpectation.new }
      let(:expected_query) { '' }

      let(:actual_request) { Consumer::Request::Actual.new(actual_method, actual_path, actual_headers, actual_body, actual_query) }

      let(:actual_method) { 'get' }
      let(:actual_path) { '/foo' }
      let(:actual_headers) { {} }
      let(:actual_body) { '' }
      let(:actual_query) { '' }

      it "matches identical requests" do
        expect(subject.matches? actual_request).to be true
      end

      context "when the methods are the same but one is symbolized" do
        let(:expected_method) { :get }
        let(:actual_method) { 'get' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context "when the methods are different" do
        let(:expected_method) { 'get' }
        let(:actual_method) { 'post' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the paths are different" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/bar' }

        it "does not match" do
          expect(subject.matches? actual_request).to be false
        end
      end

      context "when the paths vary only by a trailing slash" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/foo/' }

        it "matches" do
          expect(subject.matches? actual_request).to be true
        end
      end

      context 'request body' do
        context "when the expected body is nil and the actual body is empty" do
          let(:expected_body) { nil }
          let(:actual_body) { '' }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the expected body has no expectation and the actual body is empty" do
          let(:expected_body) { Pact::NullExpectation.new }
          let(:actual_body) { '' }

          it "matches" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context "when the expected body is nested and the actual body is nil" do
          let(:expected_body) do
            {
              a: 'a'
            }
          end

          let(:actual_body) { nil }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the bodies are different" do
          let(:expected_body) { 'foo' }
          let(:actual_body) { 'bar' }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the expected body contains matching regexes" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: /CN.*/
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "matches" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context "when the expected body contains non-matching regexes" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: /foo/
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the expected body contains matching terms" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: Term.new(matcher: /CN.*/, generate: 'CN789')
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "matches" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context "when the expected body contains non-matching terms" do
          let(:expected_body) do
            {
              name: 'Bob',
              customer_id: Term.new(matcher: /foo/, generate: 'fooool')
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              customer_id: 'CN1234'
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the expected body contains non-matching arrays" do
          let(:expected_body) do
            {
              name: 'Robert',
              nicknames: ['Bob', 'Bobert']
            }
          end

          let(:actual_body) do
            {
              name: 'Bob',
              nicknames: ['Bob']
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when the expected body contains non-matching hash where one field contains a substring of the other" do
            let(:expected_body) do
              {
                name: 'Robert',
              }
            end

            let(:actual_body) do
              {
                name: 'Rob'
              }
            end

            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
        end

        context "when the expected body contains matching arrays" do
          let(:expected_body) do
            {
              name: 'Robert',
              nicknames: ['Bob', 'Bobert']
            }
          end

          let(:actual_body) do
            {
              name: 'Robert',
              nicknames: ['Bob', 'Bobert']
            }
          end

          it "does not match" do
            expect(subject.matches? actual_request).to be true
          end
        end

        context "when a string is expected, but a number is found" do
          let(:actual_body) { { thing: 123} }
          let(:expected_body) { { thing: "123" } }

          it 'does not match' do
            expect(subject.matches? actual_request).to be false
          end
        end

        context "when unexpected keys are found in the body" do
          let(:expected_body) { {a: 1} }
          let(:actual_body) { {a: 1, b: 2} }
          context "when allowing unexpected keys" do
            let(:options) { {'allow_unexpected_keys_in_body' => true} } #From json, these will be strings
            it "matches" do
              expect(subject.matches? actual_request).to be true
            end
          end
          context "when not allowing unexpected keys" do
            let(:options) { {'allow_unexpected_keys_in_body' => false} }
            it "does not match" do
              expect(subject.matches? actual_request).to be false
            end
          end
        end
      end

      context 'request queries' do
        context "when the queries are different" do
          let(:expected_query) { 'foo' }
          let(:actual_query) { 'bar' }

          it "does not match" do
            expect(subject.matches? actual_request).to be false
          end
        end

        context 'when the expected query is a hash' do
          let(:expected_query) { {first: 'one', second: 'two'} }
          let(:actual_query) { 'second=two&first=one' }

          it 'matches regardless of order' do
            expect(subject.matches? actual_request).to be true
          end
        end

        context 'when there is no query expectation' do
          let(:expected_query) { Pact::NullExpectation.new }
          let(:actual_query) { 'bar' }

          it 'matches' do
            expect(subject.matches? actual_request).to be true
          end
        end
      end

    end
  end
end
