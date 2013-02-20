require 'net/http'
require 'uri'
require 'json'
require 'hashie'

require 'singleton'
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
          @interactions += interactions
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

      class InteractionPut

        def match? env
          env['REQUEST_PATH'] == '/interactions' &&
            env['REQUEST_METHOD'] == 'PUT'
        end

        def respond env
          interactions = Hashie::Mash.new(JSON.parse(env['rack.input'].string))[:interactions]
          InteractionList.instance.add interactions
          [200, {}, ['Added interactions']]
        end
      end

      class InteractionReplay

        REQUEST_KEYS = Hashie::Mash.new({
          'REQUEST_METHOD' => :method,
          'REQUEST_PATH' => :path,
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

        def find_response request
          matching_interactions = InteractionList.instance.interactions.select do |interaction|
            filtered_request = interaction.request.select {|key, value| request.has_key?(key)}
            Hashie::Mash.new(filtered_request) == Hashie::Mash.new(request)
          end
          raise 'Multiple interactions found!' unless matching_interactions.size < 2
          matching_interactions.empty? ? handle_unrecognised_request(request) : response_from(matching_interactions.first.response)
        end

        def handle_unrecognised_request request
          puts "No interaction found for request: "
          puts request.to_hash.inspect
          [404, {}, ['No interaction found']]
        end
        def response_from response
          [response.status, response.headers.to_hash || {}, [render_body(response.body)]]
        end

        def render_body body
          return '' unless body
          body.respond_to?(:to_hash) ? body.to_json : body.force_encoding('utf-8')
        end
      end


      def initialize
        @handlers = [
          StartupPoll.new,
          InteractionPut.new,
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
          puts e.message
          puts e.backtrace
          raise e
        end
        response
      end

    end
  end
end
