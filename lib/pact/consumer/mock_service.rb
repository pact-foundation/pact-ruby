require 'net/http'
require 'uri'
require 'json'
require 'singleton'
require 'logger'
require 'awesome_print'
require 'awesome_print/core_ext/logger' #For some reason we get an error indicating that the method 'ap' is private unless we load this specifically
require 'json/add/regexp'
require 'pact/matchers'
require 'pact/consumer/request'

AwesomePrint.defaults = {
  indent: -2,
  plain: true,
  index: false
}

module Pact
  module Consumer

    class InteractionList

      attr_reader :interactions
      attr_reader :unexpected_requests

      def initialize
        clear
      end

      # For testing, sigh
      def clear
        @interactions = []
        @matched_interactions = []
        @unexpected_requests = []
      end

      def add interactions
        @interactions << interactions
      end

      def register_matched interaction
        @matched_interactions << interaction
      end

      # Request::Actual
      def register_unexpected_request request
        @unexpected_requests << request
      end

      def all_matched?
        interaction_diffs.empty?
      end

      def missing_interactions
        @interactions - @matched_interactions
      end

      def interaction_diffs
        {
          :missing_interactions => missing_interactions,
          :unexpected_requests => unexpected_requests.collect(&:as_json)
        }.inject({}) do | hash, pair |
          hash[pair.first] = pair.last if pair.last.any?
          hash
        end
      end

      def find_candidate_interactions actual_request
        interactions.select do | interaction |
          interaction.request.matches_route? actual_request
        end        
      end      

    end

    module RackHelper
      def params_hash env
        env["QUERY_STRING"].split("&").collect{| param| param.split("=")}.inject({}){|params, param| params[param.first] = URI.decode(param.last); params }
      end
    end

    class StartupPoll

      def initialize name, logger
        @name = name
        @logger = logger
      end

      def match? env
        env['REQUEST_PATH'] == '/index.html' &&
          env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        @logger.info "#{@name} started up"
        [200, {}, ['Started up fine']]
      end
    end

    class CapybaraIdentify

      def initialize name, logger
        @name = name
        @logger = logger
      end

      def match? env
        env["PATH_INFO"] == "/__identify__"
      end

      def respond env
        [200, {}, [object_id.to_s]]
      end
    end

    class InteractionDelete

      include RackHelper

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/interactions') &&
          env['REQUEST_METHOD'] == 'DELETE'
      end

      def respond env
        @interaction_list.clear
        @logger.info "Cleared interactions before example \"#{params_hash(env)['example_description']}\""
        [200, {}, ['Deleted interactions']]
      end
    end

    class InteractionPost

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'] == '/interactions' &&
          env['REQUEST_METHOD'] == 'POST'
      end

      def respond env
        interactions = Interaction.from_hash(JSON.load(env['rack.input'].string))
        @interaction_list.add interactions
        @logger.info "Added interaction to #{@name}"
        @logger.ap interactions.as_json
        [200, {}, ['Added interactions']]
      end
    end

    module RequestExtractor

      REQUEST_KEYS = {
        'REQUEST_METHOD' => :method,
        'REQUEST_PATH' => :path,
        'QUERY_STRING' => :query,
        'rack.input' => :body
      }

      def request_as_hash_from env
        request = env.inject({}) do |memo, (k, v)|
          request_key = REQUEST_KEYS[k]
          memo[request_key] = v if request_key
          memo
        end

        request[:headers] = headers_from env
        body_string = request[:body].read

        if body_string.empty?
          request.delete :body
        else
          body_is_json = request[:headers]['Content-Type'] =~ /json/
          request[:body] =  body_is_json ? JSON.parse(body_string) : body_string
        end
        request[:method] = request[:method].downcase
        request
      end

      def headers_from env
        headers = env.reject{ |key, value| !(key.start_with?("HTTP") || key == 'CONTENT_TYPE')}
        headers.inject({}) do | hash, header |
          hash[standardise_header(header.first)] = header.last
          hash
        end
      end

      def standardise_header header
        header.gsub(/^HTTP_/, '').split("_").collect{|word| word[0] + word[1..-1].downcase}.join("-")
      end
    end

    class InteractionReplay
      include Pact::Matchers
      include RequestExtractor

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        true # default handler
      end

      def respond env
        find_response request_as_hash_from(env)
      end

      private

      def find_response request_hash
        actual_request = Request::Actual.from_hash(request_hash)
        @logger.info "#{@name} received request"
        @logger.ap actual_request.as_json
        candidate_interactions = @interaction_list.find_candidate_interactions actual_request
        matching_interactions = find_matching_interactions actual_request, from: candidate_interactions

        case matching_interactions.size
        when 0 then handle_unrecognised_request actual_request, candidate_interactions
        when 1 then handle_matched_interaction matching_interactions.first
        else
          handle_more_than_one_matching_interaction actual_request, matching_interactions
        end
      end

      def find_matching_interactions actual_request, opts
        candidate_interactions = opts.fetch(:from)
        candidate_interactions.select do | candidate_interaction |
          candidate_interaction.request.matches? actual_request
        end        
      end 

      def handle_matched_interaction interaction
        @interaction_list.register_matched interaction
        response = response_from(interaction.response)
        @logger.info "Found matching response on #{@name}:"
        @logger.ap interaction.response
        response        
      end

      def multiple_interactions_found_response actual_request, matching_interactions
        response = {
          message: "Multiple interaction found for #{actual_request.method.upcase} #{actual_request.path}", 
          matching_interactions:  matching_interactions.collect{ | interaction | request_summary_for(interaction) }
        }
        [500, {'Content-Type' => 'application/json'}, [response.to_json]]
      end

      def handle_more_than_one_matching_interaction actual_request, matching_interactions
        @logger.error "Multiple interactions found on #{@name}:"
        @logger.ap matching_interactions.collect(&:as_json)
        multiple_interactions_found_response actual_request, matching_interactions
      end

      def interaction_diffs actual_request, candidate_interactions
        candidate_interactions.collect do | candidate_interaction |
          diff = candidate_interaction.request.difference(actual_request)
          diff_summary_for candidate_interaction, diff
        end        
      end

      def diff_summary_for interaction, diff
        summary = {:description => interaction.description}
        summary[:provider_state] = interaction.provider_state if interaction.provider_state
        summary.merge(diff)
      end

      def request_summary_for interaction
        summary = {:description => interaction.description}
        summary[:provider_state] if interaction.provider_state
        summary[:request] = interaction.request
        summary
      end

      def unrecognised_request_response actual_request, interaction_diffs
        response = {
          message: "No interaction found for #{actual_request.method.upcase} #{actual_request.path}", 
          interaction_diffs:  interaction_diffs
        }
        [500, {'Content-Type' => 'application/json'}, [response.to_json]]
      end

      def log_unrecognised_request_and_interaction_diff actual_request, interaction_diffs, candidate_interactions
        @logger.error "No interaction found on #{@name} amongst expected requests \"#{candidate_interactions.map(&:description).join(', ')}\""
        @logger.error 'Interaction diffs for that route:'
        @logger.ap(interaction_diffs, :error)        
      end

      def handle_unrecognised_request actual_request, candidate_interactions
        @interaction_list.register_unexpected_request actual_request
        interaction_diffs = interaction_diffs(actual_request, candidate_interactions)
        log_unrecognised_request_and_interaction_diff actual_request, interaction_diffs, candidate_interactions
        unrecognised_request_response actual_request, interaction_diffs
      end

      def response_from response
        [response['status'], (response['headers'] || {}).to_hash, [render_body(response['body'])]]
      end

      def render_body body
        return '' unless body
        body.kind_of?(String) ? body.force_encoding('utf-8') : body.to_json
      end

      def logger_info_ap msg
        @logger.info msg
      end
    end

    class MissingInteractionsGet
      include RackHelper

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/number_of_missing_interactions') &&
            env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        number_of_missing_interactions = @interaction_list.missing_interactions.size
        @logger.info "Number of missing interactions for mock \"#{@name}\" = #{number_of_missing_interactions}"
        [200, {}, ["#{number_of_missing_interactions}"]]
      end

    end

    class VerificationGet

      include RackHelper

      def initialize name, logger, log_description, interaction_list
        @name = name
        @logger = logger
        @log_description = log_description
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/verify') &&
          env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        if @interaction_list.all_matched?
          @logger.info "Verifying - interactions matched for example \"#{example_description(env)}\""
          [200, {}, ['Interactions matched']]
        else
          @logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". Interaction diffs:"
          @logger.ap @interaction_list.interaction_diffs, :warn
          [500, {}, ["Actual interactions do not match expected interactions for mock #{@name}. See #{@log_description} for details."]]
        end
      end

      def example_description env
        params_hash(env)['example_description']
      end
    end

    class MockService

      def initialize options = {}
        options = {log_file: STDOUT}.merge options
        log_stream = options[:log_file]
        @logger = Logger.new log_stream

        log_description = if log_stream.is_a? File
           File.absolute_path(log_stream).gsub(Dir.pwd + "/", '')
        else
          "standard out/err"
        end

        interaction_list = InteractionList.new

        @name = options.fetch(:name, "MockService")
        @handlers = [
          StartupPoll.new(@name, @logger),
          CapybaraIdentify.new(@name, @logger),
          MissingInteractionsGet.new(@name, @logger, interaction_list),
          VerificationGet.new(@name, @logger, log_description, interaction_list),
          InteractionPost.new(@name, @logger, interaction_list),
          InteractionDelete.new(@name, @logger, interaction_list),
          InteractionReplay.new(@name, @logger, interaction_list)
        ]
      end

      def to_s
        "#{@name} #{super.to_s}"
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.respond env
        rescue Exception => e
          @logger.ap 'Error ocurred in mock service:'
          @logger.ap e
          @logger.ap e.backtrace
          raise e
        end
        response
      end

    end
  end
end
