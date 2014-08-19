require 'pact/provider/rspec'

class App
  def self.call env
    if env['REQUEST_METHOD'] == 'OPTIONS'
      [200, {}, []]
    else
      [500, {}, ["Expected an options request"]]
    end
  end
end

Pact.service_provider 'Provider' do
  app { App }
end