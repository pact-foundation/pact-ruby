require_relative 'pact_helper'

module ZooApp
  describe "A pact with Animal Service", :pact => true do

    before do
      AnimalServiceClient.base_uri 'localhost:1234'
    end

    describe "a call to get alligators" do

      context "when valid response is received" do
        before do
          animal_service.
            given("there are alligators").
              upon_receiving("a request for alligators").
                with({ method: :get, path: '/alligators', :headers => {'Accept' => 'application/json'} }).
                  will_respond_with({
                    status: 200,
                    headers: { 'Content-Type' => 'application/json' },
                    body: [{:name => 'Bob'}]
                  })
        end

        it "returns a list of alligators" do
          expect(AnimalServiceClient.find_alligators).to eq [ZooApp::Animals::Alligator.new(:name => 'Bob')]
        end

      end

      context "when an error response is returned" do
        before do
          animal_service.
            given("an error has occurred").
              upon_receiving("a request for alligators").
                with({ method: :get, path: '/alligators', :headers => {'Accept' => 'application/json'} }).
                  will_respond_with({
                    status: 500,
                    headers: { 'Content-Type' => 'application/json' },
                    body: {:error => 'Argh!!!'}
                  })
        end

        it "raises an error" do
          expect{ AnimalServiceClient.find_alligators }.to raise_error /Argh/
        end

      end
    end

    describe "a call to get an alligator by name" do
      context "when an alligator by the given name exists" do

        before do
          animal_service.
            given("there is an alligator named Mary").
              upon_receiving("a request for alligator Mary").
                with({ method: :get, path: '/alligators/Mary', :headers => {'Accept' => 'application/json'} }).
                  will_respond_with({
                    status: 200,
                    headers: { 'Content-Type' => 'application/json' },
                    body: {:name => 'Mary'}
                  })
        end

        it "returns the alligator" do
          expect(AnimalServiceClient.find_alligator_by_name("Mary")).to eq ZooApp::Animals::Alligator.new(:name => 'Mary')
        end

      end

      context "when an alligator by the given name does not exist" do

        before do
          animal_service.
            given("there is an alligator named Mary").
              upon_receiving("a request for alligator Mary").
                with({ method: :get, path: '/alligators/Mary', :headers => {'Accept' => 'application/json'} }).
                  will_respond_with({
                    status: 404,
                    headers: { 'Content-Type' => 'application/json' }
                  })
        end

        it "returns nil" do
          expect(AnimalServiceClient.find_alligator_by_name("Mary")).to be_nil
        end

      end
    end
  end
end