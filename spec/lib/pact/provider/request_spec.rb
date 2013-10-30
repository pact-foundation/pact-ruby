require 'spec_helper'
require 'pact/provider/request'

describe Pact::Provider::Request::Replayable do

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

  subject { described_class.new(expected_request)}

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
      let(:body) { Pact::NullExpectation.new }
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
      let(:headers) { {"Content-Type" => "text/plain", "Accept" => "application/json", "Access-Control-Request-Method" => "POST"} }
      let(:expected_headers) { {"CONTENT_TYPE" => "text/plain", "HTTP_ACCEPT" => "application/json", "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "POST"} }
      it "transforms the headers into Rack format" do
        expect(subject.headers).to eq( expected_headers )
      end
    end
    context "when headers are not specified" do
      let(:headers) { Pact::NullExpectation.new }
      it "returns an empty hash" do
        expect(subject.headers).to eq({})
      end
    end
  end
end