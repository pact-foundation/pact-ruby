module Pact
  module Provider
    module Help

      class PactDiff

        class PrintPactDiffError < StandardError; end

        attr_reader :pact_json, :output

        def initialize pact_json
          @pact_json = pact_json
        end

        def self.call pact_json
          new(pact_json).call
        end

        def call
          begin
            if diff_rel && diff_url
              header + "\n" + get_diff
            end
          rescue PrintPactDiffError => e
            return e.message
          end
        end

        private

        def header
          "The following changes have been made since the previous distinct version of this pact, and may be responsible for verification failure:\n"
        end

        def pact_hash
          @pact_hash ||= json_load(pact_json)
        end

        def links
          pact_hash['_links'] || pact_hash['links']
        end

        def diff_rel
          return nil unless links
          key = links.keys.find { | key | key =~ /diff/ && key =~ /distinct/ && key =~ /previous/}
          key ? links[key] : nil
        end

        def diff_url
          diff_rel['href']
        end

        def get_diff
          begin
            open(diff_url) { | file | file.read }
          rescue StandardError => e
            raise PrintPactDiffError.new("Tried to retrieve diff with previous pact from #{diff_url}, but received response code #{e}.")
          end
        end

        def json_load json
          JSON.load(json, nil, { max_nesting: 50 })
        end
      end
    end
  end
end
