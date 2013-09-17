require 'spec_helper'
require 'pact/consumer_contract/request'

describe Pact::Request::Replayable do

  let(:path) { '/path?something' }
  let(:body) { {a: 'body'} }
  let(:headers) { {} }
  let(:expected_request) do 
    instance_double('Pact::Request::Expected', 
      :method => 'post', 
      :full_path => path, 
      :body => body,
      :headers => headers)
  end

  subject { Pact::Request::Replayable.new(expected_request)}

  describe "method" do
    it 'returns the method' do
      expect(subject.method).to eq 'post'
    end
  end
  describe "path" do
    it "returns the full path" do
      expect(subject.path).to eq(path)
    end
  end

  describe "body" do
    context "when body is a NullExpectation" do
      let(:body) { Pact::Request::NullExpectation.new }
      it "returns an empty string, not sure if it should do this or return nil???" do
        expect(subject.body).to eq ""
      end
    end
    context "when body is an empty string" do
      let(:body) { '' }
      it "returns an empty string" do
        expect(subject.body).to eq ""
      end
    end
    context "when body is a string" do
      let(:body) { 'a string'}
      it "returns the string" do
        expect(subject.body).to eq body
      end
    end
    context "when body is a Term" do
      let(:body) { Pact::Term.new(generate: 'a', matcher: /a/) }
      it "returns the generated value" do
        expect(subject.body).to eq "a"
      end
    end
    context "when body is not a string" do
      let(:body) { {a: 'body'} }
      it "returns the object as a json string" do
        expect(subject.body).to eq body.to_json
      end
    end
  end

  describe "headers" do
    context "when headers are expected" do
      let(:headers) { {"Content-Type" => "text/plain", "Accept" => "application/json"} }
      let(:expected_headers) { {"CONTENT_TYPE" => "text/plain", "HTTP_ACCEPT" => "application/json"} }
      it "transforms the headers into Rack format" do
        expect(subject.headers).to eq( expected_headers )
      end
    end
    context "when headers are not specified" do
      let(:headers) { Pact::Request::NullExpectation.new }
      it "returns an empty hash" do
        expect(subject.headers).to eq({})
      end
    end
  end
end

shared_examples "a request" do

  describe 'matching' do
    let(:expected) do
      Pact::Request::Expected.from_hash(
        {'method' => 'get', 'path' => 'path', 'query' => /b/}
        )
    end

    let(:actual) do
      Pact::Request::Actual.from_hash({'method' => 'get', 'path' => 'path', 'query' => 'blah'})
    end

    it "should match" do
      expect(expected.difference(actual)).to eq({})
    end
  end

  describe 'full_path' do
    context "with empty path" do
      subject { described_class.from_hash({:path => '', :method => 'get'}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/"
      end
    end
    context "with a path" do
      subject { described_class.from_hash({:path => '/path', :method => 'get'}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/path"
      end
    end
    context "with a path and query" do
      subject { described_class.from_hash({:path => '/path', :method => 'get', :query => "something"}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/path?something"
      end
    end
    context "with a path and a query that is a Term" do
      subject { described_class.from_hash({:path => '/path', :method => 'get', :query => Pact::Term.new(generate: 'a', matcher: /a/)}) }
      it "returns the full path with reified path" do
        expect(subject.full_path).to eq "/path?a"
      end
    end
  end

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

    describe "as_json_with_options" do
      subject { Request::Expected.new(:get, '/path', {:header => 'value'}, {:body => 'yeah'}, "query", options) }
      context "with options" do
        let(:options) { {some: 'options'} }
        it "includes the options" do
          expect(subject.as_json_with_options[:options]).to eq options
        end
      end
      context "without options" do
        let(:options) { {} }
        it "does not include the options" do
          expect(subject.as_json_with_options.key?(:options)).to be_false
        end
      end
    end
    describe "as_json" do
      subject { Request::Expected.new(:get, '/path', {:header => 'value'}, {:body => 'yeah'}, "query", {some: 'options'}) }
      context "with options" do
        it "does not include the options" do
          expect(subject.as_json.key?(:options)).to be_false
        end
      end
    end

    describe "matching to actual requests" do

      subject { Request::Expected.new(expected_method, expected_path, expected_headers, expected_body, expected_query, options) }
      let(:options) { {} }

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
          expect(subject.match actual_request).to be_true
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

      context "when unexpected keys are found in the body" do
        let(:expected_body) { {a: 1} }
        let(:actual_body) { {a: 1, b: 2} }
        context "when allowing unexpected keys" do
          let(:options) { {'allow_unexpected_keys_in_body' => true} } #From json, these will be strings
          it "matches" do
            expect(subject.match actual_request).to be_true
          end
        end
        context "when not allowing unexpected keys" do
          let(:options) { {'allow_unexpected_keys_in_body' => false} }
          it "does not match" do
            expect(subject.match actual_request).to be_false
          end
        end
      end
    end
  end

  describe Request::Actual do
    it_behaves_like "a request"
  end
end
