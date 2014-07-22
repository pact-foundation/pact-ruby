require 'spec_helper'
require 'pact/consumer/hypermediafy_object_tree'

module Pact

  describe HypermediafyObjectTree do

    describe ".call" do
      let(:hash) { {
        'status' => '200',
        'headers' => {'Location' => 'http://example.org/some-resource'},
        'body' => {'href' => 'http://example.org'}}
      }
      let(:mock_service_base_url) { 'localhost:1234'}
      let(:host_alias) { 'example.org' }

      subject { HypermediafyObjectTree.call hash, host_alias, mock_service_base_url }

      it "replaces the host alias (example.org) with a Pact::Term" do
        expect(subject['headers']['Location']).to eq Pact::Term.new(matcher: /^http:\/\/[^\/]+\/some\-resource$/, generate: 'http://localhost:1234/some-resource')
        expect(subject['body']['href']).to eq Pact::Term.new(matcher: /^http:\/\/[^\/]+$/, generate: 'http://localhost:1234')
      end
    end

  end

end