module Pact
  module Provider
    class PrintPactDiff

      class PrintPactDiffError < StandardError; end

      attr_reader :pact_json, :output

      def initialize pact_json, output
        @pact_json = pact_json
        @output = output
      end

      def self.call pact_json, output
        new(pact_json, output).call
      end

      def call
        begin
          if diff_rel && diff_url
            output.puts(header)
            output.puts("\n")
            output.puts(get_diff)
          end
        rescue PrintPactDiffError => e
          output.puts e.message
        end
      end

      private

      def header
        orangeify "The following changes have been made since the previous distinct version and may be responsible for verification failure:"
      end

      def orangeify string
        "\e[33m#{string}\e[m"
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
          raise PrintPactDiffError.new("Tried to retrieve diff with previous pact from #{diff_url}, but received response code #{e}")
        end
      end

      def json_load json
        JSON.load(json, nil, { max_nesting: 50 })
      end

    end
  end
end
