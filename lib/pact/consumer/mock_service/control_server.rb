require 'pact/consumer/mock_service/set_up_mock_service'

module Pact
  module Consumer

    class ControlServer

      def initialize options = {}
        log_description = configure_logger options

        @handlers = [
          SetUpMockService.new("Setter Upperer", @logger)
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
        "Control Server"
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.call env
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