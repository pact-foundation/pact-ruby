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
      end
    end
  end
end
