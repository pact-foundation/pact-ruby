require 'pact/provider/rspec'

class App
  def self.call env
    [200, {'Content-Type' => 'application/json'}, []]
  end
end

Pact.service_provider 'Provider' do
  app { App }
end
