module Pact
  module Consumer
    module Configuration

      module ConfigurationExtensions
        def add_provider_verification &block
          provider_verifications << block
        end

        def provider_verifications
          @provider_verifications ||= []
        end

        def control_server_port
          @control_server_port ||= 8888
        end

        def control_server_port= port
          @control_server_port = port
        end

      end
    end
  end
end
