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
          def app &block
            self.app_block = block
          end

          def app_version application_version
            self.application_version = application_version
          end

          def app_version_tags tags
            self.tags = tags
          end

          def publish_verification_results publish_verification_results
            self.publish_verification_results = publish_verification_results
            Pact::RSpec.with_rspec_2 do
              Pact.configuration.error_stream.puts "WARN: Publishing of verification results is currently not supported with rspec 2. If you would like this functionality, please feel free to submit a PR!"
            end
          end

          def honours_pact_with consumer_name, options = {}, &block
            create_pact_verification consumer_name, options, &block
          end

          def honours_pacts_from_pact_broker &block
            create_pact_verification_from_broker &block
          end

          def builder &block
            self.app_block = lambda { RackToMessageAdapter.new(block)  }
          end
        end
      end
    end
  end
end
