require 'spec_helper'
require 'pact/request'

shared_examples "a request" do
  describe "building from a hash" do

    let(:raw_request) do
      {
        'method' => 'get',
        'path' => '/mallory',
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => 'hello mallory'
      }
    end

    subject { described_class.from_hash(raw_request) }

    its(:method) { should == 'get' }
    its(:path) { should == '/mallory' }
    its(:body) { should == 'hello mallory' }
    its(:query) { should eq Pact::Request::NullExpectation.new }

    it "blows up if method is absent" do
      raw_request.delete 'method'
      expect { described_class.from_hash(raw_request) }.to raise_error
    end

    it "blows up if path is absent" do
      raw_request.delete 'path'
      expect { described_class.from_hash(raw_request) }.to raise_error
    end

    it "does not blow up if body is missing" do
      raw_request.delete 'body'
      expect { described_class.from_hash(raw_request) }.to_not raise_error
    end

  end
end

module Pact

  describe Request::Expected do
    it_behaves_like "a request"

    describe "matching to actual requests" do

      subject { Request::Expected.new(expected_method, expected_path, expected_headers, expected_body, expected_query) }

      let(:expected_method) { 'get' }
      let(:expected_path) { '/foo' }
      let(:expected_headers) { nil }
      let(:expected_body) { nil }
      let(:expected_query) { '' }

      let(:actual_request) { Request::Actual.new(actual_method, actual_path, actual_headers, actual_body, actual_query) }

      let(:actual_method) { 'get' }
      let(:actual_path) { '/foo' }
      let(:actual_headers) { nil }
      let(:actual_body) { nil }
      let(:actual_query) { '' }

      it "matches identical requests" do
        expect(subject.match actual_request).to be_true
      end

      context "when the methods are the same but one is symbolized" do
        let(:expected_method) { :get }
        let(:actual_method) { 'get' }

        it "matches" do
          expect(subject.match actual_request).to be_true
        end
      end

      context "when the methods are different" do
        let(:expected_method) { 'get' }
        let(:actual_method) { 'post' }

        it "does not match" do
          expect(subject.match actual_request).to be_false
        end
      end

      context "when the paths are different" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/bar' }

        it "does not match" do
          expect(subject.match actual_request).to be_false
        end
      end

      context "when the paths vary only by a trailing slash" do
        let(:expected_path) { '/foo' }
        let(:actual_path) { '/foo/' }

        it "matches" do
          expect(subject.match actual_request).to be_true
        end
      end

      context "when the expected body is nil and the actual body is empty" do
        let(:expected_body) { nil }
        let(:actual_body) { '' }

        it "does not match" do
          expect(subject.match actual_request).to be_false
        end
      end

      context "when the expected body has no expectation and the actual body is empty" do
        let(:expected_body) { Request::NullExpectation.new }
        let(:actual_body) { '' }

        it "matches" do
          expect(subject.match actual_request).to be_true
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
          expect(subject.match actual_request).to be_false
        end
      end

      context "when the bodies are different" do
        let(:expected_body) { 'foo' }
        let(:actual_body) { 'bar' }

        it "does not match" do
          expect(subject.match actual_request).to be_false
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
          expect(subject.match actual_request).to be_true
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
          expect(subject.match actual_request).to be_false
        end
      end

      context "when the expected body contains matching terms" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: Term.new(matcher: /CN.*/)
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "matches" do
          expect(subject.match actual_request).to be_true
        end
      end

      context "when the expected body contains non-matching terms" do
        let(:expected_body) do
          {
            name: 'Bob',
            customer_id: Term.new(matcher: /foo/)
          }
        end

        let(:actual_body) do
          {
            name: 'Bob',
            customer_id: 'CN1234'
          }
        end

        it "does not match" do
          expect(subject.match actual_request).to be_false
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
          expect(subject.match actual_request).to be_false
        end
      end
      context "when the expected body contains non-matching hash where one field contains a substring of the other" do
        pending do
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
            expect(subject.match actual_request).to be_false
          end
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
          expect(subject.match actual_request).to be_true
        end
      end

      context "when the queries are different" do
        let(:expected_query) { 'foo' }
        let(:actual_query) { 'bar' }

        it "does not match" do
          expect(subject.match actual_request).to be_false
        end
      end

      context 'when there is no query expectation' do
        let(:expected_query) { Request::NullExpectation.new }
        let(:actual_query) { 'bar' }

        it 'matches' do
          expect(subject.match actual_request).to be_true
        end
      end

      context "when a string is expected, but a number is found" do
        let(:actual_body) { { thing: 123} }
        let(:expected_body) { { thing: "123" } }

        it 'does not match' do
          expect(subject.match actual_request).to be_false
        end
      end
    end
  end

  describe Request::Actual do
    it_behaves_like "a request"
  end
end
