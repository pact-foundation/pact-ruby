require 'pact/matchers'
require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/interaction_mismatch'
require 'pact/consumer_contract'
require 'pact/consumer/interactions_filter'

module Pact
  module Consumer

    class InteractionReplay
      include Pact::Matchers
      include RackRequestHelper

      attr_accessor :name, :logger, :interaction_list, :interactions

      def initialize name, logger, interaction_list, interactions
        @name = name
        @logger = logger
        @interaction_list = interaction_list
        @interactions = DistinctInteractionsFilter.new(interactions)
      end

      def match? env
        true # default handler
      end

      def respond env
        find_response request_as_hash_from(env)
      end

      private

      def add_verified_interaction interaction
        interactions << interaction
      end

      def find_response request_hash
        actual_request = Request::Actual.from_hash(request_hash)
        logger.info "Received request #{actual_request.method_and_path}"
        logger.debug pretty_generate actual_request
        candidate_interactions = interaction_list.find_candidate_interactions actual_request
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
        interaction_list.register_matched interaction
        add_verified_interaction interaction
        response = response_from(interaction.response)
        logger.info "Found matching response for #{interaction.request.method_and_path}"
        logger.debug pretty_generate(interaction.response)
        response
      end

      def multiple_interactions_found_response actual_request, matching_interactions
        response = {
          message: "Multiple interaction found for #{actual_request.method_and_path}",
          matching_interactions:  matching_interactions.collect{ | interaction | request_summary_for(interaction) }
        }
        [500, {'Content-Type' => 'application/json'}, [response.to_json]]
      end

      def handle_more_than_one_matching_interaction actual_request, matching_interactions
        logger.error "Multiple interactions found for #{actual_request.method_and_path}:"
        matching_interactions.each do | interaction |
          logger.debug pretty_generate(interaction)
        end
        multiple_interactions_found_response actual_request, matching_interactions
      end

      def interaction_mismatch actual_request, candidate_interactions
        InteractionMismatch.new(candidate_interactions, actual_request)
      end

      def request_summary_for interaction
        summary = {:description => interaction.description}
        summary[:provider_state] if interaction.provider_state
        summary[:request] = interaction.request
        summary
      end

      def unrecognised_request_response interaction_mismatch
        response = {
          message: "No interaction found for #{interaction_mismatch.actual_request.method_and_path}",
          interaction_diffs:  interaction_mismatch.to_hash
        }
        [500, {'Content-Type' => 'application/json'}, [response.to_json]]
      end

      def log_unrecognised_request_and_interaction_diff interaction_mismatch
        logger.error "No matching interaction found on #{name} for #{interaction_mismatch.actual_request.method_and_path}"
        logger.error 'Interaction diffs for that route:'
        logger.error(interaction_mismatch.to_s)
      end

      def handle_unrecognised_request actual_request, candidate_interactions
        interaction_mismatch = interaction_mismatch(actual_request, candidate_interactions)
        if candidate_interactions.any?
          interaction_list.register_interaction_mismatch interaction_mismatch
        else
          interaction_list.register_unexpected_request actual_request
        end
        log_unrecognised_request_and_interaction_diff interaction_mismatch
        unrecognised_request_response interaction_mismatch
      end

      def response_from response
        [response['status'], (response['headers'] || {}).to_hash, [render_body(Pact::Reification.from_term(response['body']))]]
      end

      def render_body body
        return '' unless body
        body.kind_of?(String) ? body.force_encoding('utf-8') : body.to_json
      end

      def logger_info_ap msg
        logger.info msg
      end

      #Doesn't seem to reliably pretty generate unless we go to JSON and back again :(
      def pretty_generate object
        JSON.pretty_generate(JSON.parse(object.to_json))
      end
    end
  end
end
