require_relative 'spawn_app'
require_relative 'mock_contract_service'

MOCK_CONTRACT_SERVICE_URL = "http://localhost:1234"

spawn_app MockContractService.new, 1234

RSpec.configure do |c|
  c.before(:each, :type => :feature) do
    http = Net::HTTP.new('localhost', 1234)
    request = Net::HTTP::Delete.new('/interactions')
    response = http.request(request)
  end
end