module Pact
  module Provider
    module Configuration
      class ServiceProviderConfig

        def initialize &app_block
          @app_block = app_block
        end

        def app
          @app_block.call
        end
      end
    end
  end
end