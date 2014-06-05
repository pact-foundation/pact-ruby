require 'uri'
require 'json'
require 'logger'
require 'awesome_print'
require 'awesome_print/core_ext/logger' #For some reason we get an error indicating that the method 'ap' is private unless we load this specifically
require 'pact/consumer/request'
require 'pact/consumer/mock_service/interaction_list'
require 'pact/consumer/mock_service/interaction_delete'
require 'pact/consumer/mock_service/interaction_post'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/missing_interactions_get'
require 'pact/consumer/mock_service/verification_get'
require 'pact/consumer/mock_service/log_get'
require 'pact/consumer/mock_service/pact_post'

AwesomePrint.defaults = {
  indent: -2,
  plain: true,
  index: false
}

module Pact
  module Consumer

    class MockService

      def initialize options = {}
        log_description = configure_logger options
        interaction_list = InteractionList.new

        @name = options.fetch(:name, "MockService")
        interactions = []
        @handlers = [
          MissingInteractionsGet.new(@name, @logger, interaction_list),
          VerificationGet.new(@name, @logger, interaction_list, log_description),
          InteractionPost.new(@name, @logger, interaction_list),
          InteractionDelete.new(@name, @logger, interaction_list),
          LogGet.new(@name, @logger),
          PactPost.new(@name, @logger, interactions),
          InteractionReplay.new(@name, @logger, interaction_list, interactions)
        ]
      end

      def configure_logger options
        options = {log_file: $stdout}.merge options
        log_stream = options[:log_file]
        @logger = Logger.new log_stream
        @logger.level = Pact.configuration.logger.level

        if log_stream.is_a? File
           File.absolute_path(log_stream).gsub(Dir.pwd + "/", '')
        else
          "standard out/err"
        end
      end

      def to_s
        "#{@name} #{super.to_s}"
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.respond env
        rescue StandardError => e
          @logger.error 'Error ocurred in mock service:'
          @logger.ap e, :error
          @logger.ap e.backtrace
          response = [500, {'Content-Type' => 'application/json'}, [{message: e.message, backtrace: e.backtrace}.to_json]]
        rescue Exception => e
          @logger.error 'Exception ocurred in mock service:'
          @logger.ap e, :error
          @logger.ap e.backtrace
          raise e
        end
        response
      end

    end
  end
end