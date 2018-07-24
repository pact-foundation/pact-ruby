require 'pact/hal/entity'
require 'pact/hal/http_client'

module Pact
  module Hal
    describe Entity do
      let(:http_client) do
        instance_double('Pact::Hal::HttpClient', post: provider_response)
      end

      let(:provider_response) do
        double('response', body: provider_hash, success?: true)
      end

      let(:provider_hash) do
        {
          "name" => "Provider"
        }
      end
      let(:pact_hash) do
        {
          "name" => "a name",

          "_links" => {
            "pb:provider" => {
              "href" => "http://provider"
            },
            "pb:version-tag" => {
              "href" => "http://provider/version/{version}/tag/{tag}"
            }
          }
        }
      end

      subject(:entity) { Entity.new("http://pact", pact_hash, http_client) }

      it "delegates to the properties in the data" do
        expect(subject.name).to eq "a name"
      end

      describe "post" do
        let(:post_provider) { entity.post("pb:provider", {'some' => 'data'} ) }

        it "executes an http request" do
          expect(http_client).to receive(:post).with("http://provider", '{"some":"data"}', {})
          post_provider
        end

        it "returns the entity for the relation" do
          expect(post_provider).to be_a(Entity)
        end

        context "with template params" do
          let(:post_provider) { entity._link("pb:version-tag").expand(version: "1", tag: "prod").post({'some' => 'data'} ) }

          it "posts to the expanded URL" do
            expect(http_client).to receive(:post).with("http://provider/version/1/tag/prod", '{"some":"data"}', {})
            post_provider
          end
        end
      end

      describe "can?" do
        context "when the relation exists" do
          it "returns true" do
            expect(subject.can?('pb:provider')).to be true
          end
        end

        context "when the relation does not exist" do
          it "returns false" do
            expect(subject.can?('pb:consumer')).to be false
          end
        end
      end

      describe "_link!" do
        context 'when the key exists' do
          it 'returns a Link' do
            expect(subject._link!('pb:provider')).to be_a(Link)
            expect(subject._link!('pb:provider').href).to eq 'http://provider'
          end
        end

        context 'when the key does not exist' do
          it 'raises an error' do
            expect { subject._link!('foo') }.to raise_error RelationNotFoundError, "Could not find relation 'foo' in resource at http://pact"
          end
        end
      end

      describe 'fetch' do
        context 'when the key exists' do
          it 'returns fetched value' do
            expect(subject.fetch('pb:provider')).to eq("href" => 'http://provider')
          end
        end

        context "when the key doesn't not exist" do
          it 'returns nil' do
            expect(subject.fetch('i-dont-exist')).to be nil
          end
        end

        context "when a fallback key is provided" do
          context "when the fallback value exists" do
            it "returns the fallback value" do
              expect(subject.fetch('i-dont-exist', 'pb:provider')).to eq("href" => 'http://provider')
            end
          end

          context "when the fallback value does not exist" do
            it "returns nil" do
              expect(subject.fetch('i-dont-exist', 'i-also-dont-exist')).to be nil
            end
          end
        end
      end
    end
  end
end
