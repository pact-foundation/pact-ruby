# frozen_string_literal: true

describe Pact::Provider::PactBrokerProxy do
  let(:proxy) do
    described_class.new(nil, backend: 'https://example.org', logger: Logger.new(nil))
  end
  let(:path) do
    '/pacts/provider/provider/consumer/consumer/pact-version/version'
  end
  let(:raw_body) do
    JSON.pretty_generate(
      'consumer' => { 'name' => 'consumer' },
      'provider' => { 'name' => 'provider' },
      'interactions' => []
    )
  end

  before do
    proxy.instance_variable_set(:@path, path)
  end

  ['200', 200].each do |status|
    it "rewrites a pact response with a #{status.class} status" do
      response = proxy.rewrite_response([status, {}, [raw_body]])

      expect(response[0]).to eq(status)
      expect(JSON.parse(response[2].first)).to eq(JSON.parse(raw_body))
      expect(response[1][Rack::CONTENT_LENGTH]).to eq(response[2].first.bytesize.to_s)
    end
  end

  it 'supports zero-argument reads on rack-proxy 2 request bodies' do
    request_body_stream = Rack::Proxy.const_get(:RequestBodyStream).new(StringIO.new('body'), 4)

    expect(request_body_stream.read).to eq('body')
  end
end
