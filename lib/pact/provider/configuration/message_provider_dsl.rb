require 'pact/provider/configuration/service_provider_dsl'

module Pact
  module Provider
    module Configuration
      class MessageProviderDSL < ServiceProviderDSL
        class RackToMessageAdapter
          def initialize(message_builder)
            @message_builder = message_builder
          end

          def call(env)
            request_body_json = JSON.parse(env['rack.input'].read)
            contents = @message_builder.call(request_body_json['description'])
            [200, {"Content-Type" => "application/json"}, [{ contents: contents }.to_json]]
          end
        end

        def initialize name
          super
          @mapper_block = lambda { |args|  }
        end

        dsl do
          def builder &block
            self.app_block = lambda { RackToMessageAdapter.new(block)  }
          end
        end
      end
    end
  end
end
