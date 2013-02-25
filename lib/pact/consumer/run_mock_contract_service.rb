require 'net/http'
require_relative 'spawn_app'
require_relative 'mock_service'

spawn_app MockService.new, 1234

RSpec.configure do |c|
  c.before(:each, :type => :feature) do
    http = Net::HTTP.new('localhost', 1234)
    request = Net::HTTP::Delete.new('/interactions')
    response = http.request(request)
  end
end
