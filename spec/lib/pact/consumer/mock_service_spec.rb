require 'spec_helper'
require 'pact/consumer/mock_service'

module Pact::Consumer

  describe InteractionList do
    shared_context "unexpected requests and missed interactions" do
      let(:expected_call) { {request: 'blah'} }
      let(:unexpected_call) { Pact::Request::Actual.from_hash(path: '/path', method: 'get') }
      subject {
        interactionList = InteractionList.new
        interactionList.add expected_call
        interactionList.register_unexpected_request unexpected_call
        interactionList
       }
    end

    shared_context "no unexpected requests or missed interactions exist" do
      let(:expected_call) { {request: 'blah'} }
      let(:unexpected_call) { Pact::Request::Actual.from_hash(path: '/path', method: 'get') }
      subject {
        interactionList = InteractionList.new
        interactionList.add expected_call
        interactionList.register_matched expected_call
        interactionList
       }
    end

    describe "interaction_diffs" do
      context "when unexpected requests and missed interactions exist" do
        include_context "unexpected requests and missed interactions"
        let(:expected) {
          {:missing_interactions=>[{:request=>"blah"}], :unexpected_requests=>[{:method=>"get", :path=>"/path"}]}
        }
        it "returns the unexpected requests and missed interactions" do
          expect(subject.interaction_diffs).to eq expected
        end
      end

      context "when no unexpected requests or missed interactions exist" do
        include_context "no unexpected requests or missed interactions exist"
        let(:expected) {
          {}
        }
        it "returns an empty hash" do
          expect(subject.interaction_diffs).to eq expected
        end
      end
    end

    describe "all_matched?" do
      context "when unexpected requests or missed interactions exist" do
        include_context "unexpected requests and missed interactions"
        it "returns false" do
          expect(subject.all_matched?).to be_false
        end
      end
      context "when unexpected requests or missed interactions do not exist" do
        include_context "no unexpected requests or missed interactions exist"
        it "returns false" do
          expect(subject.all_matched?).to be_true
        end
      end
    end
  end

  describe RequestExtractor do
    class TestSubject
      include RequestExtractor
    end

    let(:rack_env) {
      {
             "CONTENT_LENGTH" => "16",
               "CONTENT_TYPE" => content_type,
          "GATEWAY_INTERFACE" => "CGI/1.1",
                  "PATH_INFO" => "/donuts",
               "QUERY_STRING" => "",
                "REMOTE_ADDR" => "127.0.0.1",
                "REMOTE_HOST" => "localhost",
             "REQUEST_METHOD" => "POST",
                "REQUEST_URI" => "http://localhost:4321/donuts",
                "SCRIPT_NAME" => "",
                "SERVER_NAME" => "localhost",
                "SERVER_PORT" => "4321",
            "SERVER_PROTOCOL" => "HTTP/1.1",
            "SERVER_SOFTWARE" => "WEBrick/1.3.1 (Ruby/1.9.3/2013-02-22)",
                "HTTP_ACCEPT" => "text/plain",
            "HTTP_USER_AGENT" => "Ruby",
                  "HTTP_HOST" => "localhost:4321",
               "rack.version" => [1, 2 ],
                 "rack.input" => StringIO.new(body),
                "rack.errors" => nil,
           "rack.multithread" => true,
          "rack.multiprocess" => false,
              "rack.run_once" => false,
            "rack.url_scheme" => "http",
               "HTTP_VERSION" => "HTTP/1.1",
               "REQUEST_PATH" => "/donuts"
      }
     }

    subject { TestSubject.new }

    let(:expected_request) {
      {
            "query" => "",
           "method" => "post",
             "body" => expected_body,
             "path" => "/donuts",
          "headers" => {
              "Content-Type" => content_type,
                    "Accept" => "text/plain",
                "User-Agent" => "Ruby",
                      "Host" => "localhost:4321",
                   "Version" => "HTTP/1.1"
          }
      }
    }

    context "with a text body" do
      let(:content_type) { "application/x-www-form-urlencoded" }
      let(:body) { 'this is the body' }
      let(:expected_body) { body }

      it "extracts the body" do
        expect(subject.request_as_hash_from(rack_env)).to eq expected_request
      end
    end

    context "with a json body" do
      let(:content_type) { "application/json" }
      let(:body) { '{"a" : "body" }' }
      let(:expected_body) { {"a" => "body"} }

      it "extracts the body" do
        expect(subject.request_as_hash_from(rack_env)).to eq expected_request
      end
    end


  end
end