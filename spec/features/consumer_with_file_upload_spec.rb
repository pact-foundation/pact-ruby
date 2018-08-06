require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'
require 'faraday'
load 'pact/consumer/world.rb'

describe "A consumer with a file upload", :pact => true  do

  before :all do
    Pact.clear_configuration
    Pact.clear_consumer_world
    Pact.service_consumer "Consumer with a file upload" do
      has_pact_with "A file upload service" do
        mock_service :file_upload_service do
          verify false
          port 7777
        end
      end
    end
  end

  let(:file_to_upload) { File.absolute_path("./spec/support/text.txt") }
  let(:payload) { { file: Faraday::UploadIO.new(file_to_upload, 'text/plain') } }

  let(:connection) do
    Faraday.new(file_upload_service.mock_service_base_url + "/files") do |builder|
      builder.request :multipart
      builder.request :url_encoded
      builder.adapter :net_http
    end
  end

  let(:do_request) { connection.post { |req| req.body = payload } }

  describe "when the content matches" do

    let(:body) do
      "-------------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc\r\nContent-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\nContent-Length: 14\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a file\r\n-------------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc--\r\n\r\n"
    end

    it "returns the mocked response and verification passes" do
      file_upload_service.
        upon_receiving("a request to upload a file").with({
        method: :post,
        path: '/files',
        body: body,
        headers: {
          "Content-Type" => Pact.term(/multipart\/form\-data/, "multipart/form-data; boundary=-----------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc"),
          "Content-Length" => Pact.like("299")
        }
      }).
        will_respond_with({
        status: 200
      })

      do_request

      file_upload_service.verify("when the content matches")
    end
  end

  describe "when the content does not match" do

    let(:body) do
      "-------------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc\r\nContent-Disposition: form-data; name=\"file\"; filename=\"TEXT.txt\"\r\nContent-Length: 14\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a file\r\n-------------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc--\r\n\r\n"
    end

    it "the verification fails" do
      file_upload_service.
        upon_receiving("a request to upload another file").with({
        method: :post,
        path: '/files',
        query: "foo=bar",
        body: body,
        headers: {
          "Content-Type" => Pact.term(/multipart\/form\-data/, "multipart/form-data; boundary=-----------RubyMultipartPost-05e76cbc2adb42ac40344eb9b35e98bc"),
          "Content-Length" => Pact.like("299"),
          "Missing" => "header"
        }
      }).
        will_respond_with({
        status: 200
      })

      do_request

      expect { file_upload_service.verify("when the content matches") }.to raise_error /do not match/
    end
  end
end
