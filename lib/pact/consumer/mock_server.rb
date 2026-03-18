# frozen_string_literal: true

require "pact/ffi/mock_server"

module Pact
  module Consumer
    class MockServer
      attr_reader :host, :port, :transport, :handle, :url

      TRANSPORT_HTTP = "http"
      TRANSPORT_GRPC = "grpc"

      class MockServerCreateError < Pact::FfiError; end

      class WritePactsError < Pact::FfiError; end

      # https://docs.rs/pact_ffi/0.4.17/pact_ffi/mock_server/fn.pactffi_create_mock_server_for_transport.html
      CREATE_TRANSPORT_ERRORS = {
        -1 => {reason: :invalid_handle, status: -1, description: "An invalid handle was received. Handles should be created with pactffi_new_pact"},
        -2 => {reason: :invalid_transport_json, status: -2, description: "Transport_config is not valid JSON"},
        -3 => {reason: :mock_server_not_started, status: -3, description: "The mock server could not be started"},
        -4 => {reason: :internal_error, status: -4, description: "The method panicked"},
        -5 => {reason: :invalid_host, status: -5, description: "The address is not valid"}
      }.freeze

      # https://docs.rs/pact_ffi/0.4.17/pact_ffi/mock_server/fn.pactffi_write_pact_file.html
      WRITE_PACT_FILE_ERRORS = {
        1 => {reason: :internal_error, status: 1, description: "A general panic was caught"},
        2 => {reason: :file_not_accessible, status: 2, description: "The pact file was not able to be written"},
        3 => {reason: :mock_server_not_found, status: 3, description: "A mock server with the provided port was not found"}
      }.freeze

      def self.create_for_grpc!(pact:, host: "127.0.0.1", port: 0)
        new(pact: pact, transport: TRANSPORT_GRPC, host: host, port: port)
      end

      def self.create_for_http!(pact:, host: "127.0.0.1", port: 0)
        new(pact: pact, transport: TRANSPORT_HTTP, host: host, port: port)
      end

      def self.create_for_transport!(pact:, transport:, host: "127.0.0.1", port: 0)
        new(pact: pact, transport: transport, host: host, port: port)
      end

      def initialize(pact:, transport:, host:, port:)

        @pact = pact
        @transport = transport
        @host = host
        @port = port

        @handle = init_transport!
        # the returned handle is the port number
        # we set it here, so we can consume a port number of 0
        # and allow pact to assign a random available port
        @port = @handle
        # construct the url for the mock server
        # as a convenience for the user
        @url = "#{transport}://#{host}:#{@handle}"
        # TODO: handle auto-GC of native memory
        # ObjectSpace.define_finalizer(self, proc do
        #   cleanup
        # end)
      end

      def write_pacts!(dir)
        result = PactFfi::MockServer.write_pact_file(@handle, dir, false)
        return result if WRITE_PACT_FILE_ERRORS[result].blank?

        error = WRITE_PACT_FILE_ERRORS[result]
        raise WritePactsError.new("There was an error while trying to write pact file to #{dir}", error[:reason], error[:status])
      end

      def matched?
        PactFfi::MockServer.matched(@handle)
      end

      def mismatches
        PactFfi::MockServer.mismatches(@handle)
      end

      def cleanup
        PactFfi::MockServer.cleanup(@handle)
      end

      def cleanup_plugins
        PactFfi::PluginConsumer.cleanup_plugins(@handle)
      end

      def free_pact_handle
        PactFfi.free_pact_handle(@handle)
      end

      private

      def init_transport!
        handle = PactFfi::MockServer.create_for_transport(@pact, @host, @port, @transport, nil)
        # the returned handle is the port number
        return handle if CREATE_TRANSPORT_ERRORS[handle].blank?

        error = CREATE_TRANSPORT_ERRORS[handle]
        raise MockServerCreateError.new("There was an error while trying to create mock server for transport:#{@transport}", error[:reason], error[:status])
      end
    end
  end
end
