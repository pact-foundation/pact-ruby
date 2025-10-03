require 'pact/generators'
require 'pact/provider/request'

describe Pact::Generators do
  it 'apply_generators for path' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      generators: {
        'path' => {
          'type' => 'ProviderState',
          'expression' => '/path/${itemID}'
        }
      }
    })
    state_params = {
      'itemID' => 2
    }
    request = Pact::Provider::Request::Replayable.new(expected_request, state_params)
    expect(request.path).to eq('/path/2')
  end

  it 'apply_generators for headers' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      headers: {
        'Authorization' => 'Bearer 123'
      },
      generators: {
        'header' => {
          '$.Authorization' => {
            'expression' => 'Bearer ${accessToken}',
            'type' => 'ProviderState'
          }
        }
      }
    })
    state_params = {
      'accessToken' => 'ABC'
    }
    request = Pact::Provider::Request::Replayable.new(expected_request, state_params)
    expect(request.headers).to eq({
      'HTTP_AUTHORIZATION' => 'Bearer ABC'
    })
  end

  it 'apply_generators for body' do
    expected_request = Pact::Request::Expected.from_hash({
      method: 'GET',
      path: '/path/1',
      body: {
        'result' => [
          '12345F'
        ]
      },
      generators: {
        'body' => {
          '$.result[0]' => {
            'type' => 'RandomHexadecimal'
          }
        }
      }
    })
    request = Pact::Provider::Request::Replayable.new(expected_request)
    expect(JSON.parse(request.body)['result'][0].length).to eq(8)
  end
end
