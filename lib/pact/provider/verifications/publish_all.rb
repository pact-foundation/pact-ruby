require'pact/provider/verifications/create'
require'pact/provider/verifications/publish'

module Pact
  module Provider
    module Verifications
      class PublishAll

        def self.call pact_jsons, rspec_summary
          new(pact_jsons, rspec_summary).call
        end

        def initialize pact_jsons, rspec_summary
          @pact_jsons = pact_jsons
          @rspec_summary = rspec_summary
        end

        def call
          verifications.collect do | pair |
            Publish.call(pair.first, pair.last)
          end
        end

        private

        def verifications
          pact_jsons.collect do | pact_json |
            [pact_json, Create.call(pact_json, rspec_summary)]
          end
        end

        attr_reader :pact_jsons, :rspec_summary
      end
    end
  end
end
