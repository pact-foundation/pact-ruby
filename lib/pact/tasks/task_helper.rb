require 'pact/provider/pact_helper_locator'
require 'rake/file_utils'
require 'shellwords'

module Pact
  module TaskHelper

    extend self

    def execute_pact_verify pact_uri = nil, pact_helper = nil, rspec_opts = nil
      execute_cmd verify_command(pact_helper || Pact::Provider::PactHelperLocater.pact_helper_path, pact_uri, rspec_opts)
    end

    def handle_verification_failure
      exit_status = yield
      abort if exit_status != 0
    end

    def verify_command pact_helper, pact_uri, rspec_opts
      command_parts = []
      # Clear SPEC_OPTS, otherwise we can get extra formatters, creating duplicate output eg. CI Reporting.
      # Allow deliberate configuration using rspec_opts in VerificationTask.
      command_parts << "SPEC_OPTS=#{Shellwords.escape(rspec_opts || '')}"
      command_parts << FileUtils::RUBY
      command_parts << "-S pact verify"
      command_parts << "--pact-helper" << (pact_helper.end_with?(".rb") ? pact_helper : pact_helper + ".rb")
      (command_parts << "--pact-uri" << pact_uri) if pact_uri
      command_parts << "--pact-broker-username" << ENV['PACT_BROKER_USERNAME'] if ENV['PACT_BROKER_USERNAME']
      command_parts << "--pact-broker-password" << ENV['PACT_BROKER_PASSWORD'] if ENV['PACT_BROKER_PASSWORD']
      command_parts << "--backtrace" if ENV['BACKTRACE'] == 'true'
      command_parts << "--backtrace" if ENV['BACKTRACE'] == 'true'
      command_parts << "--description #{Shellwords.escape(ENV['PACT_DESCRIPTION'])}" if ENV['PACT_DESCRIPTION']
      command_parts << "--provider-state #{Shellwords.escape(ENV['PACT_PROVIDER_STATE'])}" if ENV['PACT_PROVIDER_STATE']
      command_parts.flatten.join(" ")
    end

    def execute_cmd command
      $stdout.puts command
      system(command) ? 0 : 1
    end

  end
end