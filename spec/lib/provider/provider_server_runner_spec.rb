# frozen_string_literal: true

describe Pact::Provider::ProviderServerRunner do
  let(:http_client) do
    Faraday.new do |conn|
      conn.response :json
      conn.request :json
    end
  end

  let(:make_request) do
    server.run { http_client.post('http://localhost:9001/setup-provider', request_body) }
  end

  let(:server) do
    subject.tap do |s|
      s.add_setup_state('state1') {}
      s.add_teardown_state('state1') {}
    end
  end

  context 'with setup callback' do
    let(:request_body) do
      { 'action' => 'setup', 'params' => { 'param1' => 'value1' }, 'state' => 'state1' }
    end

    it 'succeeds' do
      expect_any_instance_of(Pact::Provider::ProviderStateServlet).to receive(:call_setup).and_call_original

      response = make_request
      expect(response.status).to eq(200)
    end
  end

  context 'with teardown callback' do
    let(:request_body) do
      { 'action' => 'teardown', 'params' => { 'param1' => 'value1' }, 'state' => 'state1' }
    end

    it 'succeeds' do
      expect_any_instance_of(Pact::Provider::ProviderStateServlet).to receive(:call_teardown).and_call_original

      response = make_request
      expect(response.status).to eq(200)
    end
  end

  context 'with unknown state callback' do
    let(:request_body) do
      { 'action' => 'unknown', 'params' => { 'param1' => 'value1' }, 'state' => 'state1' }
    end

    it 'succeeds' do
      expect_any_instance_of(Pact::Provider::ProviderStateServlet).not_to receive(:call_setup)
      expect_any_instance_of(Pact::Provider::ProviderStateServlet).not_to receive(:call_teardown)

      response = make_request
      expect(response.status).to eq(200)
    end
  end

  context 'with unknown data' do
    let(:request_body) { 'non-json data' }

    it 'fails' do
      response = make_request
      expect(response.status).to eq(500)
    end
  end
end
