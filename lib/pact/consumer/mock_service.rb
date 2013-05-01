require 'net/http'
require 'uri'
require 'json'
require 'hashie'
require 'singleton'
require 'awesome_print'
require 'core/ext/hash'

module Pact
  module Consumer

    class MockService

      class InteractionList
        include Singleton

        attr_reader :interactions

        def initialize
          @interactions = []
        end

        def add interactions
          @interactions << interactions
        end

        def clear
          @interactions.clear
        end
      end

      class StartupPoll
        def match? env
          env['REQUEST_PATH'] == '/index.html' &&
            env['REQUEST_METHOD'] == 'GET'
        end

        def respond env
          [200, {}, ['Started up fine']]
        end
      end

      class InteractionDelete

        def match? env
          env['REQUEST_PATH'] == '/interactions' &&
            env['REQUEST_METHOD'] == 'DELETE'
        end

        def respond env
          InteractionList.instance.clear
          [200, {}, ['Deleted interactions']]
        end
      end

      class InteractionPost

        def match? env
          env['REQUEST_PATH'] == '/interactions' &&
            env['REQUEST_METHOD'] == 'POST'
        end

        def respond env
          interactions = Hashie::Mash.new(JSON.load(env['rack.input'].string))
          InteractionList.instance.add interactions
          [200, {}, ['Added interactions']]
        end
      end

      class InteractionReplay

        REQUEST_KEYS = Hashie::Mash.new({
          'REQUEST_METHOD' => :method,
          'REQUEST_PATH' => :path,
          'QUERY_STRING' => :query,
          'rack.input' => :body
        })

        def match? env
          true # default handler
        end

        def respond env
          find_response request_from(env)
        end

        private

        def request_from env
          request = env.inject({}) do |memo, (k, v)|
            request_key = REQUEST_KEYS[k]
          memo[request_key] = v if request_key
          memo
          end

          mashed_request = Hashie::Mash.new request
          body_string = mashed_request[:body].read
          if (body_string.empty?)
            mashed_request.delete :body
          else
            mashed_request[:body] = Hashie::Mash.new(JSON.parse(body_string))
          end
          mashed_request[:method] = mashed_request[:method].downcase
          mashed_request
        end

        def find_response raw_request
          actual_request = Request::Actual.from_hash(raw_request)
          candidates = []
          matching_interactions = InteractionList.instance.interactions.select do |interaction|
            expected_request = Request::Expected.from_hash(interaction.request)
            candidates << expected_request if expected_request.matches_route? actual_request
            expected_request.match actual_request
          end
          raise 'Multiple interactions found!' if matching_interactions.size > 1
          matching_interactions.empty? ? handle_unrecognised_request(actual_request, candidates) : response_from(matching_interactions.first.response)
        end

        def handle_unrecognised_request request, candidates
          puts 'No interaction found for request: '
          request_json = request.as_json
          ap request_json
          puts 'Interaction diffs for that route:'
          candidates.map(&:as_json).each do |candidate|
            ap candidate.diff_with_actual request_json
          end
          [404, {}, ['No interaction found']]
        end

        def response_from response
          [response.status, (response.headers || {}).to_hash, [render_body(response.body)]]
        end

        def render_body body
          return '' unless body
          body.respond_to?(:to_hash) ? body.to_json : body.force_encoding('utf-8')
        end
      end

      def initialize
        @handlers = [
          StartupPoll.new,
          InteractionPost.new,
          InteractionDelete.new,
          InteractionReplay.new
        ]
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.respond env
        rescue Exception => e
          puts 'Error ocurred in mock service:'
          ap e
          ap e.backtrace
          raise e
        end
        response
      end

    end
  end
end
