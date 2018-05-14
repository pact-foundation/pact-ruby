require 'pact/hal/http_client'

module Pact
  module Hal
    describe HttpClient do

      before do
        allow(Retry).to receive(:until_true) { |&block| block.call }
      end

      subject { HttpClient.new(username: 'foo', password: 'bar' ) }

      describe "get" do
        let!(:request) do
          stub_request(:get, "http://example.org/").
            with(  headers: {
              'Accept'=>'application/hal+json',
              'Authorization'=>'Basic Zm9vOmJhcg=='
              }).
            to_return(status: 200, body: response_body, headers: {'Content-Type' => 'application/json'})
        end

        let(:response_body) { {some: 'json'}.to_json }
        let(:do_get) { subject.get('http://example.org') }

        it "performs a get request" do
          do_get
          expect(request).to have_been_made
        end

        context "with get params" do
          let!(:request) do
            stub_request(:get, "http://example.org/?foo=hello+world&bar=wiffle").
              to_return(status: 200)
          end

          let(:do_get) { subject.get('http://example.org', { 'foo' => 'hello world', 'bar' => 'wiffle' }) }

          it "correctly converts and encodes get params" do
             do_get
             expect(request).to have_been_made
          end
        end


        it "retries on failure" do
          expect(Retry).to receive(:until_true)
          do_get
        end

        it "returns a response" do
          expect(do_get.body).to eq({"some" => "json"})
        end
      end

      describe "post" do
        let!(:request) do
          stub_request(:post, "http://example.org/").
            with(  headers: {
              'Accept'=>'application/hal+json',
              'Authorization'=>'Basic Zm9vOmJhcg==',
              'Content-Type'=>'application/json'
              },
              body: request_body).
            to_return(status: 200, body: response_body, headers: {'Content-Type' => 'application/json'})
        end

        let(:request_body) { {some: 'data'}.to_json }
        let(:response_body) { {some: 'json'}.to_json }

        let(:do_post) { subject.post('http://example.org/', request_body) }

        it "performs a post request" do
          do_post
          expect(request).to have_been_made
        end

        it "calls Retry.until_true" do
          expect(Retry).to receive(:until_true)
          do_post
        end

        it "returns a response" do
          expect(do_post.body).to eq({"some" => "json"})
        end

        context "with custom headers" do
          let!(:request) do
            stub_request(:post, "http://example.org/").
              with(  headers: {
                'Accept'=>'foo'
                }).
              to_return(status: 200)
          end

          let(:do_post) { subject.post('http://example.org/', request_body, {"Accept" => "foo"} ) }

          it "performs a post request with custom headers" do
            do_post
            expect(request).to have_been_made
          end
        end
      end
    end
  end
end
