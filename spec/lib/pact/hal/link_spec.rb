require 'pact/hal/link'
require 'pact/hal/entity'
require 'pact/hal/http_client'

module Pact
  module Hal
    describe Link do
      let(:http_client) do
        instance_double('Pact::Hal::HttpClient', post: response)
      end

      let(:response) do
        instance_double('Pact::Hal::HttpClient::Response', success?: success, body: response_body)
      end

      let(:success) { true }

      let(:entity) do
        instance_double('Pact::Hal::Entity')
      end

      let(:attrs) do
        {
          'href' => 'http://foo/{bar}',
          'title' => 'title',
          method: :post
        }
      end

      let(:response_body) do
        {
          'some' => 'body'
        }
      end

      subject { Link.new(attrs, http_client) }

      describe "#run" do
        before do
          allow(Pact::Hal::Entity).to receive(:new).and_return(entity)
        end

        let(:do_run) { subject.run('foo' => 'bar') }

        it "executes the configured http request" do
          expect(http_client).to receive(:post)
          do_run
        end

        it "creates an Entity" do
          expect(Pact::Hal::Entity).to receive(:new).with(response_body, http_client, response)
          do_run
        end

        it "returns an Entity" do
          expect(do_run).to eq entity
        end

        context "when an error response is returned" do
          before do
            allow(Pact::Hal::ErrorEntity).to receive(:new).and_return(entity)
          end

          let(:success) { false }

          it "creates an ErrorEntity" do
            expect(Pact::Hal::ErrorEntity).to receive(:new).with(response_body, http_client, response)
            do_run
          end
        end
      end

      describe "#get" do

      end

      describe "#put" do

      end

      describe "#expand" do
        it "returns a duplicate Link with the expanded href" do
          expect(subject.expand(bar: 'wiffle').href).to eq "http://foo/wiffle"
        end
      end
    end
  end
end
